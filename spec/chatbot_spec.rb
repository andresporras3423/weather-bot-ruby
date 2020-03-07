require_relative '../lib/keys'
require_relative '../lib/test_classes'
require_relative '../lib/botclient'
require_relative '../lib/chatbot'

RSpec.describe Chatbot do
  let(:botclient) { Botclient.new(telegram_token, weather_key, false) }
  describe 'tests method celsius_weather' do
    it 'test when param is nil' do
      expect(botclient.chatbot.celsius_weather(nil)).to eql(nil)
    end
    it 'test when passed a valid parameter' do
      expect(botclient.chatbot.celsius_weather(Weather.new(293.15))).to eql('20.0°C')
    end
    it 'test when passed a valid parameter and format is F' do
      botclient.chatbot.chosen_format = 'F'
      expect(botclient.chatbot.celsius_weather(Weather.new(293.15))).to eql('68.0°F')
    end
    it 'test when passed a valid parameter and format is K' do
      botclient.chatbot.chosen_format = 'K'
      expect(botclient.chatbot.celsius_weather(Weather.new(293.15))).to eql('293.15°K')
    end
  end
  describe 'tests method give_bot_message' do
    it 'test when param temperature is nil' do
      expect(botclient.chatbot.give_bot_message(nil, 'bogotá', 'invalid data') do |x, y|
        "temperature in #{x} is #{y}"
      end).to eql('invalid data')
    end
    it 'test when param temperature is valid' do
      expect(botclient.chatbot.give_bot_message('16°C', 'bogotá', 'invalid data') do |x, y|
        "temperature in #{x} is #{y}"
      end).to eql('temperature in bogotá is 16°C')
    end
  end
  describe 'tests method update_format' do
    it 'test when format is not valid' do
      expect(botclient.chatbot.update_format(Msg.new("/format #{Regexp.last_match(1124)}"))).to eql('invalid format')
    end
    it 'test when format is valid' do
      expect(botclient.chatbot.update_format(Msg.new('/format f'))).to eql('new format is °F')
    end
  end
  describe 'tests method update_interval' do
    it 'test when interval is not valid' do
      msg = Msg.new("/interval #{Regexp.last_match(1124)}")
      expect(botclient.chatbot.update_interval(msg)).to eql('invalid interval')
    end
    it 'test when interval is valid' do
      expect(botclient.chatbot.update_interval(Msg.new('/interval 2m'))).to eql('new interval in 2 minutes')
    end
  end
end
