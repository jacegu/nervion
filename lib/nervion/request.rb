require 'em-http'
require_relative 'oauth_header'

module Nervion
  class Request
    attr_reader :http_method, :uri, :params

    def initialize(http_method, uri, params = {})
      @uri, @http_method, @params = uri, http_method, params
    end

    def headers
      { authorization: OAuthHeader.for(self) }
    end

    def start
      EventMachine::HttpRequest.new(uri).send http_method, head: headers, query: @params
    end
  end
end
