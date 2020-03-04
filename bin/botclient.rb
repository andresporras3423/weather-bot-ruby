require 'telegram/bot'
require 'openweather2'
require 'geocoder'
require_relative 'option'
require_relative 'chatbot'

class Botclient
  attr_reader :chatbot, :token_telegram, :key_openweather, :geo
  def initialize(token_telegram, key_openweather, init)
    option1 = Option.new('d', 86_400, 'days')
    option2 = Option.new('h', 3600, 'hours')
    option3 = Option.new('m', 60, 'minutes')
    option4 = Option.new('s', 1, 'seconds')
    @chatbot = Chatbot.new([option1, option2, option3, option4])
    @token_telegram = token_telegram
    @key_openweather = key_openweather
    configure_openweather
    return unless init

    begin_telegram_client
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
        answer_user_message(message, bot) unless message.text.nil?
        answer_user_location(message, bot) unless message.location.nil?
      end
    end
  end

  def answer_user_message(message, bot)
    case message.text.downcase
    when '/start'
      start_message = '*WELCOME, HUMAN.*, please share location for automatic
      updates of the temperature. For more options please type /tutorial'
      bot.api.send_message(chat_id: message.chat.id, text: start_message, parse_mode: 'Markdown')
    when '/tutorial'
      tutorial_message = create_tutorial
      bot.api.send_message(chat_id: message.chat.id, text: tutorial_message, parse_mode: 'Markdown')
    when '/no_more'
      chatbot.no_more = true
      bot.api.send_message(chat_id: message.chat.id, text: 'OK!, no more temperature updates')
    else
      answer_by_regex(message, bot)
    end
  end

  def answer_by_regex(message, bot)
    bot_message = case message.text.downcase
                  when %r{/format}
                    chatbot.update_format(message)
                  when /interval/
                    chatbot.update_interval(message)
                  when /zip:/
                    get_by_zip(message)
                  when /coord:/
                    get_by_coord(message)
                  else
                    get_by_city(message)
                  end
    bot.api.send_message(chat_id: message.chat.id, text: bot_message)
  end

  def create_tutorial
    tutorial_message = ['*Miami*']
    tutorial_message.push('Get temperature of miami')
    tutorial_message.push('*coord:  4.5 74.25*')
    tutorial_message.push('Get temperature of place with latitude 4.5 and longitude 74.25')
    tutorial_message.push('*zip:  33101*')
    tutorial_message.push('Get temperature of place with zip code 33101')
    tutorial_message.push('*/format c*')
    tutorial_message.push('Use celsius format, the other options are f (farenheit) and k (kelvin)')
    tutorial_message.push('*/interval 10m*')
    tutorial_message.push('updates of temperature every 10 minutes,
    the other options are s (seconds), h (hour), d (days)')
    tutorial_message.push('*/no_more*')
    tutorial_message.push('Stop automatic updates of the temperature')
    tutorial_message.inject { |total, line| total + "\n" + line }
  end

  def answer_user_location(message, bot)
    chatbot.no_more = false
    lon = message.location.longitude
    lat = message.location.latitude
    chat_id = message.chat.id
    geo = capture_error([lat, lon], 'geocode')
    if geo.nil?
      bot.api.send_message(chat_id: chat_id, text: 'a problem has occurred')
      return
    end
    update_temperature(lat, lon, geo, message, bot)
  end

  def update_temperature(lat, lon, geo, _message, bot)
    Thread.new do
      loop do
        break if chatbot.no_more

        weather = capture_error([lat, lon], 'weather_coord')
        temperature = chatbot.celsius_weather(weather)
        bot_message = chatbot.give_bot_message(temperature, geo.first.city, 'a problem has occurred') do |x, y|
          "temperature in #{x} is #{y}"
        end
        bot.api.send_message(chat_id: chat_id, text: bot_message)
        sleep(chatbot.interval)
      end
    end
  end

  def capture_error(params, type)
    begin
      case type
      when 'geocode'
        message_error = 'a problem has occurred'
        return Geocoder.search([params[0].to_s, params[1].to_s])
      when 'weather_coord'
        message_error = 'a problem has occurred'
        return Openweather2.get_weather(lat: params[0].to_s, lon: params[1].to_s)
      when 'weather_zip'
        message_error = 'invalid data by error'
        return Openweather2.get_weather(zip: params[0].to_i)
      when 'weather_city'
        message_error = 'invalid data by error'
        return Openweather2.get_weather(city: params[0])
      end
    rescue StandardError => e
      puts("#{message_error}: #{e}")
    end
    nil
  end

  def get_by_zip(message)
    zipcode = message.text.downcase.gsub('zip:', '').gsub(/\s+/m, '')
    weather = capture_error([zipcode], 'weather_zip')
    temperature = chatbot.celsius_weather(weather)
    chatbot.give_bot_message(temperature, zipcode, 'invalid data') { |x, y| "temperature in zip:#{x} is #{y}" }
  end

  def get_by_coord(message)
    coords = message.text.downcase.gsub('coord:', '').gsub(/\s+/m, ' ').strip.split(' ')
    weather = capture_error([coords[0].to_f, coords[1].to_f], 'weather_coord') if coords.all?(/\A\d+\.?\d*\Z/)
    temperature = chatbot.celsius_weather(weather)
    chatbot.give_bot_message(temperature, "#{coords[0].to_f} #{coords[1].to_f}", 'invalid data') do |x, y|
      "temperature in coord:#{x} is #{y}"
    end
  end

  def get_by_city(message)
    city = message.text.downcase.gsub(/\s+/m, '')
    weather = capture_error([city], 'weather_city')
    temperature = chatbot.celsius_weather(weather)
    chatbot.give_bot_message(temperature, city, 'invalid data') { |x, y| "temperature in #{x} is #{y}" }
  end
end
