require_relative '../lib/botclient'

telegram_token = '1123681465:AAGnPY8UnDj-O6kGBkU9sz_vl9EB68cp-OM'
weather_key = 'a71219e79a6b01978ac3a9f3ffccca37'
Botclient.new(telegram_token, weather_key, true)
