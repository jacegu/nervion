require 'em-http'
require_relative 'oauth_header'

module Nervion
  class Request
    HEADERS_FOR_COMPRESSED_STREAM = {
      'content-type'    => 'application/x-www-form-urlencoded',
      'user-agent'      => 'nervion twitter streaming api client',
      'accept-encoding' => 'deflate, gzip',
      'keep-alive'      => 'true'
    }

    attr_reader :http_method, :uri, :params

    def initialize(http_method, uri, params = {})
      @uri, @http_method, @params = uri, http_method, params
    end

    def start
      EventMachine::HttpRequest.new(uri).send http_method, head: headers, query: @params
    end

    def headers
      HEADERS_FOR_COMPRESSED_STREAM.merge 'authorization' => OAuthHeader.for(self)
    end
  end
end
