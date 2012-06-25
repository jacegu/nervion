require 'nervion/stream_parser'

module Nervion
  class StreamHandler
    def initialize(callbacks, stream_parser = StreamParser.new)
      @callbacks, @stream_parser = callbacks, stream_parser
      @stream_parser.on_json_parsed = @callbacks[:message]
    end

    def <<(data)
      @stream_parser << data
    end

    def handle_http_error(error)
      @stream_parser.reset!
      @callbacks[:http_error].call(error.status, error.body)
    end

    def handle_network_error
      @stream_parser.reset!
      @callbacks[:network_error].call
    end
  end
end
