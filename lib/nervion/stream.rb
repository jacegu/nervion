require 'yajl'
require 'eventmachine'
require_relative 'http_parser'

module Nervion
  class Stream < EM::Connection
    def initialize(*args)
      @request  = args[0]
      @callback = args[1]
    end

    def post_init
      @http_parser = Nervion::HttpParser.new(setup_json_parser)
    end

    def connection_completed
      start_tls
      send_data @request
    end

    def receive_data(data)
      @http_parser << data
    end

    def unbind
      SDTERR.puts 'Connection was closed out'
      EM.stop
    end

    private

    def setup_json_parser
      Yajl::Parser.new(symbolize_keys: true).tap do |parser|
        parser.on_parse_complete = @callback
      end
    end
  end
end
