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

    attr_reader :http_method, :uri, :params, :oauth_params

    def initialize(http_method, uri, params = {}, oauth_params = {})
      @uri = uri
      @http_method = http_method
      @params = params
      @oauth_params = oauth_params
    end

    def start
      EventMachine::HttpRequest.new(uri).send http_method, head: headers, query: @params
    end

    def headers
      HEADERS_FOR_COMPRESSED_STREAM.merge 'authorization' => OAuthHeader.for(self)
    end
  end
end
