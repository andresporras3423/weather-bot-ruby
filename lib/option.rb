class Option
  attr_reader :time, :number, :format_time
  def initialize(time, number, format_time)
    @time = time
    @number = number
    @format_time = format_time
  end
end
