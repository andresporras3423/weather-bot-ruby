class Chatbot
  attr_reader :options
  attr_accessor :interval, :no_more, :chosen_format
  def initialize(options)
    @options = options
    @interval=60
    @no_more=false
    @chosen_format="C"
  end

  def celsius_weather(weather)
    return nil if weather==nil

    if chosen_format=='C'
      celsius= (weather.temperature-273.15).round(2)
      return "#{celsius}°C"
    elsif chosen_format=='F'
      farenheit= (((weather.temperature-273.15)*1.8)+32).round(2)
      return "#{farenheit}°F"
    end
    return "#{weather.temperature}°K"
  end
  
  def give_bot_message(temperature, place, error_message)
    temperature_message = yield place, temperature
    return temperature.nil? ? error_message : temperature_message
  end
end