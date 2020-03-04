require_relative '../bin/botclient'
require_relative '../bin/test_classes'

token_telegram = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'
key_weather = 'a71219e79a6b01978ac3a9f3ffccca37'

RSpec.describe Botclient do
  let(:botclient) { Botclient.new(token_telegram, key_weather, false) }
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
  describe 'tests method capture_error' do
    it 'test when geocode and invalid params' do
      expect(botclient.capture_error([1000, -1000], 'geocode')).not_to eql(Array)
    end
    it 'test when geocode and valid params' do
      expect(botclient.capture_error([4, 70], 'geocode').class).to eql(Array)
    end
    it 'test when weather_coord and invalid params' do
      (expect do
        botclient.capture_error([1000, -1000], 'weather_coord')
      end
      ).to output("a problem has occurred: Something was wrong!\n").to_stdout
    end
    it 'test when weather_coord and valid params' do
      expect { botclient.capture_error([4, 70], 'weather_coord') }.to output('').to_stdout
    end
    it 'test when weather_zip and invalid params' do
      (expect do
        botclient.capture_error(['11111'], 'weather_zip')
      end
      ).to output("invalid data by error: Something was wrong!\n").to_stdout
    end
    it 'test when weather_zip and valid params' do
      expect { botclient.capture_error(['33101'], 'weather_zip') }.to output('').to_stdout
    end
    it 'test when weather_city and invalid params' do
      (expect do
        botclient.capture_error(['lalaland'], 'weather_city')
      end
      ).to output("invalid data by error: Something was wrong!\n").to_stdout
    end
    it 'test when weather_city and valid params' do
      expect { botclient.capture_error(['london'], 'weather_city') }.to output('').to_stdout
    end
  end
end
