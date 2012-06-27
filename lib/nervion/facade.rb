require 'nervion/callback_table'
require 'nervion/client'
require 'nervion/request'
require 'nervion/configuration'

module Nervion
  # Sets up the callback to be called upon HTTP errors (when the response from
  # Twitter's Streaming API has a status above 200).
  #
  # @param [Proc] callback the callback
  # @return [self] to allow callback setup chaining
  def self.on_http_error(&callback)
    callback_table[:http_error] = callback
    self
  end

  # Sets up the callback to be called upon network errors or unexpected
  # disconnection.
  #
  # @param [Proc] callback the callback
  # @return [self] to allow callback setup chaining
  def self.on_network_error(&callback)
    callback_table[:network_error] = callback
    self
  end

  # Sets up the message callback and starts streaming the sample endpoint.
  #
  # @see https://dev.twitter.com/docs/api/1/get/statuses/sample
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#delimited
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#stall_warnings
  #
  # @param [hash] params the parameters submitted to the sample endpoint
  # @option params [Boolean] :delimited specifies whether messages should be
  #   length-delimited.
  # @option params [Boolean] :stall_warnings specifies whether stall warnings
  #   should be delivered.
  # @param [Proc] callback the callback
  def self.sample(params = {}, &callback)
    stream sample_endpoint(params), callback
  end

  # Sets up the message callback and starts streaming the filter endpoint.
  #
  # @note At least one predicate parameter (follow, locations, or track) must be
  #   specified.
  #
  # @see https://dev.twitter.com/docs/api/1/get/statuses/filter
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#follow
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#track
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#locations
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#delimited
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#stall_warnings
  #
  # @param [hash] params the parameters submitted to the sample endpoint
  # @option params [String] :follow a comma separated list of user IDs,
  #   indicating the users to return statuses for in the stream.
  # @option params [String] :track keywords to track. Phrases of keywords are
  #   specified by a comma-separated list.
  # @option params [String] :locations Specifies a set of bounding boxes to track.
  # @option params [Boolean] :delimited specifies whether messages should be
  #   length-delimited.
  # @option params [Boolean] :stall_warnings specifies whether stall warnings
  #   should be delivered.
  # @param [Proc] callback the callback
  def self.filter(params, &callback)
    stream filter_endpoint(params), callback
  end

  # Sets up the message callback and starts streaming the firehose endpoint.
  #
  # @note This endpoint requires a special access level.
  # @since 0.0.2
  #
  # @see https://dev.twitter.com/docs/api/1/get/statuses/firehose
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#count
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#delimited
  # @see https://dev.twitter.com/docs/streaming-apis/parameters#stall_warnings
  #
  # @param [hash] params the parameters submitted to the sample endpoint
  # @option params [Integer] :count the number of messages to backfill.
  # @option params [Boolean] :delimited specifies whether messages should be
  #   length-delimited.
  # @option params [Boolean] :stall_warnings specifies whether stall warnings
  #   should be delivered.
  # @param [Proc] callback the callback
  def self.firehose(params = {}, &callback)
    stream firehose_endpoint(params), callback
  end

  # Stops streaming
  def self.stop
    raise 'Nervion is not running' if @client.nil?
    @client.stop
  end

  private

  def self.callback_table
    @callback_table ||= CallbackTable.new
  end

  def self.stream(endpoint, callback)
    raise_not_configured_error unless Configuration.configured?
    raise_no_message_callback_error if callback.nil?
    callback_table[:message] = callback
    new_client.tap { |c| c.stream endpoint, callback_table }
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

  def self.firehose_endpoint(params)
    get FIREHOSE_ENDPOINT, params, Configuration
  end

  def self.raise_not_configured_error
    raise "You need to setup the authentication information for Nervion to work.\nPlease, check out #{AUTHENTICATION_README_URL}"
  end

  def self.raise_no_message_callback_error
    raise "You have to setup a message callback.\nPlease, check out #{MSG_CALLBACK_README_URL}"
  end

  STREAM_API_HOST   = 'stream.twitter.com'
  STREAM_API_PORT   = 443
  SAMPLE_ENDPOINT   = "https://#{STREAM_API_HOST}/1/statuses/sample.json"
  FILTER_ENDPOINT   = "https://#{STREAM_API_HOST}/1/statuses/filter.json"
  FIREHOSE_ENDPOINT = "https://#{STREAM_API_HOST}/1/statuses/firehose.json"

  AUTHENTICATION_README_URL = 'https://github.com/jacegu/nervion#authentication'
  MSG_CALLBACK_README_URL   = 'https://github.com/jacegu/nervion#message-callback'

end
