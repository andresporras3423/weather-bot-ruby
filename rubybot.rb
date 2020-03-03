require 'telegram/bot'
require "openweather2"
require 'geocoder'
# require 'whenever'
require 'json'
require 'httparty'
token = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'

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
        weather = Openweather2.get_weather(city: message.text)
        bot.api.send_message(chat_id: message.chat.id, text: "temperature in #{message.text} is: #{weather.temperature-275.15}°C")
      end
    end
    if message.location != nil
      Thread.new { 
        loop do
          lon = message.location.longitude
          lat = message.location.latitude
          chat_id = message.chat.id
          weather = Openweather2.get_weather(lon: lon, lat: lat)
          geo = Geocoder.search([lat.to_s, lon.to_s])
          bot.api.send_message(chat_id: chat_id, text: "current weather in #{geo.first.city} is: #{weather.temperature-275.15}°C")
          sleep(60)
          break if message.text=="/no_more"
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
