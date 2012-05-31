require 'http/parser'

module Nervion
  class HttpParser
    attr_reader :json_parser

    def initialize(json_parser)
      @json_parser = json_parser
      @http_parser = setup_http_parser
    end

    def <<(http_stream)
      @http_parser << http_stream
    end

    private

    def setup_http_parser
      Http::Parser.new.tap do |parser|
        parser.on_body = lambda { |chunk| process(chunk) }
      end
    end

    def process(chunk)
      if @http_parser.status_code == 200
        parse_json_from chunk
      else
        handle_error_in chunk
      end
    end

    def parse_json_from(chunk)
      @json_parser << chunk
    end

    def handle_error_in(chunk)
      STDERR.puts "#{@http_parser.status_code}:"
      STDERR.puts chunk
      raise 'error'
    end
  end
end
