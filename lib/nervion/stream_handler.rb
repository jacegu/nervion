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
    rescue HttpError => error
      handle_http_error error
    end

    private

    def handle_http_error(error)
      @callbacks[:http_error].call(error.status, error.body)
      @http_parser.reset!
      raise error
    end

  end
end
