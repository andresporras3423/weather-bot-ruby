require 'telegram/bot'
require "openweather2"
require 'geocoder'
require 'json'
require 'httparty'
token = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'

Openweather2.configure do |config|
  config.endpoint = 'http://api.openweathermap.org/data/2.5/weather'
  config.apikey = 'a71219e79a6b01978ac3a9f3ffccca37'
end

# def show_board
#   row1 = ['  1 ', '|', ' 2 ', '|', ' 3 ']
#   mrow = ['----', '|', '----', '|', '----']
#   row2 = [' 4 ', '|', ' 5 ', '|', ' 6 ']
#   row3 = [' 7 ', '|', ' 8 ', '|', ' 9 ']
#   board = [row1, mrow, row2, mrow, row3]
#   i = 0
#   print_board=""
#   while i < board.length
#     j = 0
#     while j < board[i].length
#       print_board += board[i][j]
#       j += 1
#     end
#     print_board+= "\n"
#     i += 1
#   end
#   return print_board
# end

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when "/start"
      bot.api.send_message(chat_id: message.chat.id, text: "#{message.location} Welcome human. Please, share your location for automatic messages of the temperature in your city every hour. Type /tutorial for a complete tutorial ")
      
      # weather_data = JSON.parse("https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22")
      # response = HTTParty.get("https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=b6907d289e10d714a6e88b30761fae22")
      # response.parsed_response
      # geo = Geocoder.search([message.from.location.longitude, message.location.latitude])
      
      # loop do
      #   sleep(60)
      #   bot.api.send_message(chat_id: message.chat.id, text: "current wheather is #{Openweather2.get_weather(city: 'london')}")
      # end
    # when "city"
    #   bot.api.send_message(chat_id: message.chat.id, text: "your city is: #{message.successful_payment.order_info.shipping_address.city}")
    # else
    #   if message.location!=nil
    #     weather = Openweather2.get_weather(lon: message.location.longitude, lat: message.location.latitude)
    #     geo = Geocoder.search([message.from.location.longitude, message.location.latitude])
    #     bot.api.send_message(chat_id: message.chat.id, text: "current weather in #{geo.first.city} is: #{weather.temperature}")
    #   end
    end
    # if message.location!=nil
    
    # end
  end
end

#message.from.first_name
#https://github.com/lucasocon/openweather/blob/d5f49d3c567bd1ac3e055a65189661d8d3851c7f/lib/openweather2/weather.rb#L2