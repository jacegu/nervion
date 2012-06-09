require 'yajl'
require 'nervion/http_parser'

module Nervion
  class StreamHandler

    def initialize(http_parser, json_parser, callbacks)
      @http_parser, @json_parser = http_parser, json_parser
      @callbacks = callbacks
      json_parser.on_parse_complete = @callbacks[:status]
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

  end
end
