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

    def reset!
      @http_parser.reset!
    end

    private

    def setup_http_parser
      Http::Parser.new.tap { |parser| parser.on_body = method(:process) }
    end

    def process(chunk)
      if request_successful?
        parse_json_from chunk
      else
        handle_error_in chunk
      end
    end

    def request_successful?
      @http_parser.status_code == 200
    end

    def parse_json_from(chunk)
      @json_parser << chunk
    end

    def handle_error_in(chunk)
      raise HttpError.new(status_code, condense_in_one_line(chunk))
    end

    def status_code
      @http_parser.status_code
    end

    def condense_in_one_line(chunk)
      chunk.split("\n").map { |line| line.strip }.join
    end
  end

  class HttpError < Exception
    attr_reader :status, :body

    def initialize(status, body)
      @status, @body = status, body
    end
  end
end
