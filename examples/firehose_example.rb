require 'nervion'

# Setup your own keys here
Nervion.configure do |config|
  config.consumer_key = ''
  config.consumer_secret = ''
  config.access_token = ''
  config.access_token_secret = ''
end

# This will cause a 403: User not in role message unless you have the level of
# access required to stream the firehose endpoint.
Nervion.firehose { |status| puts status }
