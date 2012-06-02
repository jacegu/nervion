require_relative 'stream'
require_relative 'request'
require_relative 'configuration'

module Nervion
  STREAM_API_HOST = 'stream.twitter.com'
  SAMPLE_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/sample.json"
  FILTER_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/filter.json"

  def self.sample(params = {}, &callback)
     Client.stream sample_endpoint(params), &callback
  end

  def self.filter(params, &callback)
     Client.stream filter_endpoint(params), &callback
  end

  private

  def self.sample_endpoint(params)
     get SAMPLE_ENDPOINT, params, Configuration
  end

  def self.filter_endpoint(params)
    post FILTER_ENDPOINT, params, Configuration
  end

  class Client
    def self.stream(request, &callback)
      EM.run do
        EM.connect STREAM_API_HOST, 443, Stream, request, callback
      end
    end
  end
end
