require 'telegram/bot'
require "openweather2"
require 'geocoder'
require_relative "option"
require_relative "chatbot"


class Botclient
  attr_reader :chatbot, :token_telegram, :key_openweather, :geo
  def initialize(token_telegram, key_openweather, init)
    @chatbot = Chatbot.new([Option.new("d",86400, "days"),Option.new("h",3600, "hours"),Option.new("m",60, "minutes"),Option.new("s",1, "seconds")])
    @token_telegram = token_telegram
    @key_openweather = key_openweather
    return unless init

    configure_openweather()
    begin_telegram_client()
  end

  def configure_openweather
    Openweather2.configure do |config|
      config.endpoint = 'http://api.openweathermap.org/data/2.5/weather'
      config.apikey = key_openweather
    end
  end

  def begin_telegram_client
    Telegram::Bot::Client.run(token_telegram) do |bot|
      bot.listen do |message|
        if message.text!=nil
          answer_user_message(message, bot)
        end
        if message.location != nil
          answer_user_location(message, bot)
        end
      end
    end
  end

  def answer_user_message(message, bot)
    case message.text.downcase
    when '/start'
      start_message = "Welcome human, please share location for automatic updates of the weather every hour. For more options please type /tutorial"
      bot.api.send_message(chat_id: message.chat.id, text: start_message)
    when '/no_more'
      chatbot.no_more=true
      bot.api.send_message(chat_id: message.chat.id, text: "OK!, no more temperature updates")
    when /\/format/
      bot_message = update_format(message)
      bot.api.send_message(chat_id: message.chat.id, text: bot_message)
    when /\/interval/
      bot_message = update_interval(message)
      bot.api.send_message(chat_id: message.chat.id, text: bot_message)
    when  /zip:/
      bot_message = get_by_zip(message)
      bot.api.send_message(chat_id: message.chat.id, text: bot_message)
    when  /coord:/
      bot_message = get_by_coord(message)
      bot.api.send_message(chat_id: message.chat.id, text: bot_message)
    else
      bot_message = get_by_city(message)
      bot.api.send_message(chat_id: message.chat.id, text: bot_message)
    end
  end

  def answer_user_location(message, bot)
    chatbot.no_more=false
    lon = message.location.longitude
    lat = message.location.latitude
    chat_id = message.chat.id
    geo=nil
    geo = capture_error([lat, lon], "geocode")
    if geo==nil
      bot.api.send_message(chat_id: chat_id, text: "a problem has occurred")
      return
    end
    Thread.new { 
      loop do
        break if chatbot.no_more
        weather=nil
        weather = capture_error([lat, lon], "weather_coord")
        temperature = chatbot.celsius_weather(weather)
        bot_message = chatbot.give_bot_message(temperature, geo.first.city, "a problem has occurred") {|x, y| "temperature in #{x} is #{y}"}
        bot.api.send_message(chat_id: chat_id, text: bot_message)
        sleep(chatbot.interval)
      end
    }
  end

  def capture_error(params, type)
    message_error=nil
    begin
      case type
      when "geocode"
        message_error="a problem has occurred"
        return Geocoder.search([params[0].to_s, params[1].to_s])
      when "weather_coord"
        message_error="a problem has occurred"
        return Openweather2.get_weather(lat: params[0].to_s, lon: params[1].to_s) 
      when "weather_zip"
        message_error="invalid data by error"
        return Openweather2.get_weather(zip: params[0].to_i)
      when "weather_city"
        message_error="invalid data by error"
        return Openweather2.get_weather(city: params[0])
      end
    rescue => exception
      puts("#{message_error}: #{exception}")
    end
    return nil
  end

  def update_format(message)
    temp_format = message.text.downcase.gsub('/format', '').gsub(/\s+/m, '')
    if temp_format=~/\A[kfc]{1}\Z/ 
      chatbot.chosen_format = temp_format.upcase
      return "new format is °#{chatbot.chosen_format}"
    end
    return "invalid format"
  end

  def update_interval(message)
    temp_interval = message.text.downcase.gsub('/interval', '').gsub(/\s+/m, '')
    if temp_interval =~ /\A[1-9]+[0-9]*[smhd]{1}\Z/
      amount = temp_interval[0..(temp_interval.length-2)].to_i
      chosen_option = chatbot.options.find{|opt| opt.time==temp_interval[temp_interval.length-1]}
      chosen_format_time = amount==1 ? chosen_option.format_time[0..(chosen_option.format_time.length-2)] : chosen_option.format_time
      chatbot.interval= amount*chosen_option.number
      return "new interval in #{amount} #{chosen_format_time}"
    end
    return "invalid interval"
  end

  def get_by_zip(message)
    zipcode = message.text.downcase.gsub('zip:', '').gsub(/\s+/m, '')
    weather = nil
    weather = capture_error([zipcode], "weather_zip")
    temperature = chatbot.celsius_weather(weather)
    return chatbot.give_bot_message(temperature, zipcode, "invalid data") {|x, y| "temperature in zip:#{x} is #{y}"}
  end

  def get_by_coord(message)
    coords = message.text.downcase.gsub('coord:', '').gsub(/\s+/m, ' ').strip.split(" ")
    weather=nil
    weather = capture_error([coords[0].to_f, coords[1].to_f], "weather_coord")  if coords.all?(/\A\d+\.?\d*\Z/)
    temperature = chatbot.celsius_weather(weather)
    return chatbot.give_bot_message(temperature, "#{coords[0].to_f} #{coords[1].to_f}", "invalid data") {|x, y| "temperature in coord:#{x} is #{y}"}
  end

  def get_by_city(message)
    city = message.text.downcase.gsub(/\s+/m, '')
    weather = nil
    weather = capture_error([city], "weather_city")
    temperature = chatbot.celsius_weather(weather)
    return chatbot.give_bot_message(temperature, city, "invalid data") {|x, y| "temperature in #{x} is #{y}"}
  end
end


# def capture_geocoder_error(lat, lon)
#   begin
#     return Geocoder.search([lat.to_s, lon.to_s]) 
#   rescue => exception
#     puts("a problem has occurred: #{exception}")
#   end
# end

# def capture_openweather_error(lat, lon)
#   begin
#     return Openweather2.get_weather(lon: lon, lat: lat)
#   rescue => exception
#     puts("a problem has occurred: #{exception}")
#   end
# end
