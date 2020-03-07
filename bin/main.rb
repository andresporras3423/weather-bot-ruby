require_relative '../lib/botclient'
require_relative '../lib/keys'

Botclient.new(telegram_token, weather_key, true)
