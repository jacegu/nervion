require 'yajl'
require 'nervion/http_parser'

module Nervion
  class StreamHandler

    def initialize(callbacks)
      @callbacks = callbacks
    end

    def post_init
      @http_parser = Nervion::HttpParser.new(setup_json_parser)
    end

    def receive_data(data)
      @http_parser << data
    rescue Unsuccessful => error
      @callbacks.unsuccessful_request.call(error.status, error.body)
    end



    private

    def setup_json_parser
      Yajl::Parser.new(symbolize_keys: true).tap do |parser|
        parser.on_parse_complete = @callbacks.status
      end
    end
  end
end
