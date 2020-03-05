class Chatbot
  attr_reader :options
  attr_accessor :interval, :no_more, :chosen_format
  def initialize(options)
    @options = options
    @interval = 60
    @no_more = false
    @chosen_format = 'C'
  end

  def celsius_weather(weather)
    return nil if weather.nil?

    if chosen_format == 'C'
      celsius = (weather.temperature - 275.15).round(2)
      return "#{celsius}°C"
    elsif chosen_format == 'F'
      farenheit = (((weather.temperature - 275.15) * 1.8) + 32).round(2)
      return "#{farenheit}°F"
    end
    "#{weather.temperature}°K"
  end

  def give_bot_message(temperature, place, error_message)
    temperature_message = yield place, temperature
    temperature.nil? ? error_message : temperature_message
  end

  def update_format(message)
    temp_format = message.text.downcase.gsub('/format', '').gsub(/\s+/m, '')
    if temp_format =~ /\A[kfc]{1}\Z/
      @chosen_format = temp_format.upcase
      return "new format is °#{chosen_format}"
    end
    'invalid format'
  end

  def update_interval(message)
    temp_interval = message.text.downcase.gsub('/interval', '').gsub(/\s+/m, '')
    if temp_interval =~ /\A[1-9]+[0-9]*[smhd]{1}\Z/
      amount = temp_interval[0..(temp_interval.length - 2)].to_i
      chosen_option = options.find { |opt| opt.time == temp_interval[temp_interval.length - 1] }
      chosen_format_time = if amount == 1
                             chosen_option.format_time[0..(chosen_option.format_time.length - 2)]
                           else
                             chosen_option.format_time
                           end
      @interval = amount * chosen_option.number
      return "new interval in #{amount} #{chosen_format_time}"
    end
    'invalid interval'
  end
end
