class Msg
  attr_accessor :text
  def initialize(text)
    @text = text
  end
end

class Weather
  attr_accessor :temperature
  def initialize(temperature)
    @temperature = temperature
  end
end
