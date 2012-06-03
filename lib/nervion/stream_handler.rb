require 'yajl'
require 'nervion/http_parser'

module Nervion
  class StreamHandler

    def initialize(http_parser, json_parser, callbacks)
      @http_parser = http_parser
      @json_parser = json_parser
      @callbacks   = callbacks

      json_parser.on_parse_complete = @callbacks[:status]
    end

    def <<(data)
      @http_parser << data
    rescue Unsuccessful => error
      @callbacks[:unsuccessful_request].call(error.status, error.body)
    end

  end
end
