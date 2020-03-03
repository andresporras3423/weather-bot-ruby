require 'telegram/bot'
require "openweather2"
require 'geocoder'
require_relative 'option'
# require 'whenever'
require 'json'
require 'httparty'
token = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'
$no_more=false
$chosen_format='C'
$interval=60
$options = [Option.new("d",86400),Option.new("h",3600),Option.new("m",60),Option.new("s",1)]

def celsius_weather(weather)
  return nil if weather==nil

  if $chosen_format=='C'
    celsius= (weather.temperature-273.15).round(2)
    return "#{celsius}°C"
  elsif $chosen_format=='F'
    farenheit= (((weather.temperature-273.15)*1.8)+32).round(2)
    return "#{farenheit}°F"
  end
  return "#{weather.temperature}°K"
end

Openweather2.configure do |config|
  config.endpoint = 'http://api.openweathermap.org/data/2.5/weather'
  config.apikey = 'a71219e79a6b01978ac3a9f3ffccca37'
end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    if message.text!=nil
      if message.text=="/start"
        bot.api.send_message(chat_id: message.chat.id, text: "Welcome human, please share location for automatic updates of the weather every hour. For more options please type /tutorial")
      elsif message.text!="/no_more"
        case message.text.downcase
        when /\/format/
          temp_format = message.text.downcase.gsub('/format', '').gsub(/\s+/m, '')
          if temp_format=~/\A[kfc]{1}\Z/ 
            $chosen_format = temp_format.upcase
            bot.api.send_message(chat_id: message.chat.id, text: "new format is °#{$chosen_format}")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "invalid format")
          end
        when /\/interval/
          temp_interval = message.text.downcase.gsub('/interval', '').gsub(/\s+/m, '')
          if temp_interval =~ /\A[1-9]+[0-9]*[smhd]{1}\Z/
            $interval= temp_interval[0..(temp_interval.length-2)]*$options.find{|opt| opt.time==temp_interval[temp_interval.length-1]}.number
            bot.api.send_message(chat_id: message.chat.id, text: "new interval in #{$interval} seconds")
          else
            bot.api.send_message(chat_id: message.chat.id, text: "invalid interval")
          end
        when /zip:/
          zipcode = message.text.downcase.gsub('zip:', '').gsub(/\s+/m, '')
          begin
            weather = Openweather2.get_weather(zip: zipcode.to_i)
          rescue => exception
            puts("invalid data by error: #{exception}")
          end
          temperature = celsius_weather(weather)
          bot_message = temperature.nil? ? "invalid data" : "temperature in zip:#{zipcode} is: #{temperature}"
          bot.api.send_message(chat_id: message.chat.id, text: bot_message)
        when /coord:/
          coords = message.text.downcase.gsub('coord:', '').gsub(/\s+/m, ' ').strip.split(" ")
          weather=nil
          begin
            weather = Openweather2.get_weather(lat: coords[0].to_f, lon:coords[1].to_f) if coords.all?(/\A\d+\.?\d*\Z/)
          rescue => exception
            puts("invalid data by error: #{exception}")
          end
          temperature = celsius_weather(weather)
          bot_message = temperature.nil? ? "invalid data" : "temperature in coord:#{coords[0].to_f} #{coords[1].to_f} is: #{temperature}"
          bot.api.send_message(chat_id: message.chat.id, text: bot_message)
        else
          city = message.text.downcase.gsub(/\s+/m, '')
          begin
            weather = Openweather2.get_weather(city: city)
          rescue => exception
            puts("invalid data by error: #{exception}")
          end
          temperature = celsius_weather(weather)
          bot_message = temperature.nil? ? "invalid data" : "temperature in #{city} is: #{temperature}"
          bot.api.send_message(chat_id: message.chat.id, text: bot_message)
        end
      else
        $no_more=true;
      end
    end
    if message.location != nil
      $no_more=false;
      lon = message.location.longitude
      lat = message.location.latitude
      chat_id = message.chat.id
      geo=nil
      begin
        geo = Geocoder.search([lat.to_s, lon.to_s])
      rescue => exception
        puts("the next problem has occurred: #{exception}")
      end
      if geo==nil
        bot.api.send_message(chat_id: chat_id, text: "a problem has accurred")
        break
      end
      Thread.new { 
        loop do
          break if $no_more
          weather=nil
          begin
            weather = Openweather2.get_weather(lon: lon, lat: lat)
          rescue => exception
            puts("the next problem has occurred: #{exception}")
          end
          temperature = celsius_weather(weather)
          bot_message = temperature.nil? ? "a problem has occurred" : "temperature in #{geo.first.city} is: #{temperature}"
          bot.api.send_message(chat_id: chat_id, text: bot_message)
          sleep($interval)
        end
      }
    end
  end
end

#https://ruby-doc.org/core-2.5.1/Thread.html
#https://github.com/lucasocon/openweather/blob/d5f49d3c567bd1ac3e055a65189661d8d3851c7f/lib/openweather2/weather.rb#L2
#https://samples.openweathermap.org/data/2.5/weather?q=Cartagena&appid=a71219e79a6b01978ac3a9f3ffccca37
#https://openweathermap.org/current
#http://rwarbelow.github.io/ruby-and-apis/openweathermap-api
#https://github.com/lucasocon/openweather
#https://home.openweathermap.org/api_keys
#https://core.telegram.org/bots/api#location
#https://github.com/eljojo/telegram_bot/blob/master/example/bot.rb
#https://dl.icewarp.com/online_help/203030104.htm ruby regex tutorial
#https://www.rubyguides.com/2015/06/ruby-regex/ ruby regex tutorial