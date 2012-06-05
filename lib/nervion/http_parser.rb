require 'http/parser'

module Nervion
  class HttpParser
    attr_reader :json_parser, :http_parser

    def initialize(json_parser)
      @json_parser = json_parser
      @http_parser = setup_http_parser
    end

    def <<(http_stream)
      @http_parser << http_stream
    end

    private

    def setup_http_parser
      Http::Parser.new.tap { |parser| parser.on_body = method(:process) }
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
      @http_parser = setup_http_parser
      raise Unsuccessful.new(status_code, remove_empty_lines(chunk))
    end

    def status_code
      @http_parser.status_code
    end

    def remove_empty_lines(chunk)
      chunk.gsub(/^\s*$/,'')
    end
  end

  class Unsuccessful < Exception
    attr_reader :status, :body

    def initialize(status, body)
      @status, @body = status, body
    end
  end
end
