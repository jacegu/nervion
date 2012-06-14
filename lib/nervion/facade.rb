require 'nervion/callback_table'
require 'nervion/client'
require 'nervion/request'
require 'nervion/configuration'

module Nervion
  STREAM_API_HOST = 'stream.twitter.com'
  STREAM_API_PORT = 443
  SAMPLE_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/sample.json"
  FILTER_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/filter.json"

  def self.on_http_error(&callback)
    callback_table[:http_error] = callback
    self
  end

  def self.on_network_error(&callback)
    callback_table[:network_error] = callback
    self
  end

  def self.sample(params = {}, &callback)
    callback_table[:status] = callback
    new_client.tap { |c| c.stream sample_endpoint(params), callback_table }
  end

  def self.filter(params, &callback)
    callback_table[:status] = callback
    new_client.tap { |c| c.stream filter_endpoint(params), callback_table }
  end

  def self.stop
    raise 'Nervion is not running' if @client.nil?
    @client.stop
  end

  private

  def self.callback_table
    @callback_table ||= CallbackTable.new
  end

  def self.new_client
    @client = Client.new(STREAM_API_HOST, STREAM_API_PORT)
  end

  def self.sample_endpoint(params)
     get SAMPLE_ENDPOINT, params, Configuration
  end

  def self.filter_endpoint(params)
    post FILTER_ENDPOINT, params, Configuration
  end
end
