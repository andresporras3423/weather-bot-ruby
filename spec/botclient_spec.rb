require_relative '../lib/test_classes'
require_relative '../lib/botclient'

token_telegram = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'
key_weather = 'a71219e79a6b01978ac3a9f3ffccca37'

RSpec.describe Botclient do
  describe 'tests openweather method' do
    it 'test key is invalid' do
      botclient = Botclient.new(token_telegram, '1234asdf', false)
      (expect do
        botclient.capture_error(['miami'], 'weather_city')
      end
      ).to output("invalid data by error: Something was wrong!\n").to_stdout
    end
    it 'test key is valid' do
      botclient = Botclient.new(token_telegram, key_weather, false)
      (expect do
        botclient.capture_error(['miami'], 'weather_city')
      end
      ).to output('').to_stdout
    end
  end
  describe 'tests method capture_error' do
    botclient = Botclient.new(token_telegram, key_weather, false)
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
