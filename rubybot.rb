require 'telegram/bot'
require "openweather2"
require 'geocoder'
# require 'whenever'
require 'json'
require 'httparty'
token = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'
no_more=false

def celsius_weather(weather)
  return nil if weather==nil
  
  return (weather.temperature-275.15).round(2)
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
        when /zip:/
          zipcode = message.text.downcase.gsub('zip:', '').gsub(/\s+/m, '')
          begin
            weather = Openweather2.get_weather(zip: zipcode.to_i)
          rescue => exception
            puts("invalid data by error: #{exception}")
          end
          temperature = celsius_weather(weather)
          bot_message = temperature.nil? ? "invalid data" : "temperature in zip:#{zipcode} is: #{temperature}°C"
          bot.api.send_message(chat_id: message.chat.id, text: bot_message)
        when /coord:/
          coords = message.text.downcase.gsub('coord:', '').gsub(/\s+/m, ' ').strip.split(" ")
          weather=nil
          begin
            weather = Openweather2.get_weather(lat: coords[0].to_f, lon:coords[1].to_f)
          rescue => exception
            puts("invalid data by error: #{exception}")
          end
          temperature = celsius_weather(weather)
          bot_message = temperature.nil? ? "invalid data" : "temperature in #{message.text} is: #{temperature}°C"
          bot.api.send_message(chat_id: message.chat.id, text: bot_message)
        else
          weather = Openweather2.get_weather(city: message.text)
          temperature = (weather.temperature-275.15).round(2)
          bot.api.send_message(chat_id: message.chat.id, text: "temperature in #{message.text} is: #{temperature}°C")
        end
      else
        no_more=true;
      end
    end
    if message.location != nil
      no_more=false;
      Thread.new { 
        loop do
          break if no_more

          lon = message.location.longitude
          lat = message.location.latitude
          chat_id = message.chat.id
          weather = Openweather2.get_weather(lon: lon, lat: lat)
          temperature = (weather.temperature-275.15).round(2)
          geo = Geocoder.search([lat.to_s, lon.to_s])
          bot.api.send_message(chat_id: chat_id, text: "current weather in #{geo.first.city} is: #{temperature}°C")
          sleep(60)
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
