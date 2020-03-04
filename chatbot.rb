class Chatbot
  def initialize()
    
  end

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
end