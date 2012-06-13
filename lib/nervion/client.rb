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

  def self.on_network_error(&callback)
    @callbacks[:network_error] = callback
    self
  end

  def self.sample(params = {}, &callback)
    @callbacks[:status] = callback
    @client = Client.new
    @client.stream sample_endpoint(params), @callbacks
  end

  def self.filter(params, &callback)
    @callbacks[:status] = callback
    @client = Client.new
    @client.stream filter_endpoint(params), @callbacks
  end

  def self.stop
    @client.stop
  end

  private

  def self.sample_endpoint(params)
     get SAMPLE_ENDPOINT, params, Configuration
  end

  def self.filter_endpoint(params)
    post FILTER_ENDPOINT, params, Configuration
  end

  class Client
    def initialize(host = STREAM_API_HOST, port = 443)
      @host = host
      @port = port
      @json_parser = Yajl::Parser.new(symbolize_keys: true)
      @http_parser = HttpParser.new(@json_parser)
    end

    def stream(request, callbacks)
      @stream_handler = StreamHandler.new(@http_parser, @json_parser, callbacks)
      EM.run { EM.connect @host, @port, Stream, request, @stream_handler }
    end

    def stop
      @stream_handler.close_stream
      EM.stop
    end
  end
end
