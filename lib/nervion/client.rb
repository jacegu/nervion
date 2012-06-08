$: << File.join(File.dirname(__FILE__), '..')

require 'nervion/configuration'
require 'nervion/request'
require 'nervion/stream'
require 'nervion/stream_handler'

module Nervion
  STREAM_API_HOST = 'stream.twitter.com'
  SAMPLE_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/sample.json"
  FILTER_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/filter.json"

  @callbacks = {
    status: lambda{},
    http_error: ->(status, body){ STDERR.puts "#{status}: #{body}" }
  }

  def self.on_http_error(&callback)
    @callbacks[:http_error] = callback
    self
  end

  def self.sample(params = {}, &callback)
    @callbacks[:status] = callback
    Client.stream sample_endpoint(params), @callbacks
  end

  def self.filter(params, &callback)
    @callbacks[:status] = callback
    Client.stream filter_endpoint(params), @callbacks
  end

  private

  def self.sample_endpoint(params)
     get SAMPLE_ENDPOINT, params, Configuration
  end

  def self.filter_endpoint(params)
    post FILTER_ENDPOINT, params, Configuration
  end

  class Client
    def self.stream(request, callbacks)
      new.stream request, callbacks
    end

    def initialize(host = STREAM_API_HOST, port = 443)
      @host = host
      @port = port
      @json_parser = Yajl::Parser.new(symbolize_keys: true)
      @http_parser = HttpParser.new(@json_parser)
    end

    def stream(request, callbacks)
      stream_handler = StreamHandler.new(@http_parser, @json_parser, callbacks)
      EM.run { EM.connect @host, @port, Stream, request, stream_handler }
    end
  end
end
