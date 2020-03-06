require_relative '../lib/botclient'

telegram_token = '1109360723:AAHam4xsAf-7wgF8Hjt6ACbxxOH66cimbaM'
weather_key = 'a71219e79a6b01978ac3a9f3ffccca37'
Botclient.new(telegram_token, weather_key, true)
