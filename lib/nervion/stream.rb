require 'yajl'
require 'eventmachine'
require_relative 'http_parser'

module Nervion
  class Stream < EM::Connection
    INACTIVITY_TIMEOUT = 1.0

    def initialize(*args)
      @request  = args[0]
      @callback = args[1]
    end

    def post_init
      @http_parser = Nervion::HttpParser.new(setup_json_parser)
    end

    def connection_completed
      configure
      send_data @request
    end

    def receive_data(data)
      @http_parser << data
    end

    private

    def setup_json_parser
      Yajl::Parser.new(symbolize_key: true).tap do |parser|
        parser.on_parse_complete = @callback
      end
    end

    def configure
      set_comm_inactivity_timeout INACTIVITY_TIMEOUT
      start_tls
    end
  end
end
