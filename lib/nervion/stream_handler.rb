require 'yajl'
require 'nervion/http_parser'

module Nervion
  class StreamHandler

    def initialize(callbacks)
      @callbacks = callbacks
      @http_parser = HttpParser.new(setup_json_parser)
    end

    def <<(data)
      @http_parser << data
    end

    def handle_http_error(error)
      @http_parser.reset!
      @callbacks[:http_error].call(error.status, error.body)
    end

    def handle_network_error
      @http_parser.reset!
      @callbacks[:network_error].call
    end

    private

    def setup_json_parser
      Yajl::Parser.new(symbolize_keys: true).tap do |json_parser|
        json_parser.on_parse_complete = @callbacks[:status]
      end
    end
  end
end
