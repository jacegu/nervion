require 'em-http'
require_relative 'oauth_header'

module Nervion
  class Request
    attr_reader :uri, :params, :oauth_params

    def initialize(uri, params = {}, oauth_params = {})
      @uri, @params, @oauth_params = uri, params, oauth_params
    end

    def headers
      { authorization: OAuthHeader.for(self) }
    end

    def get
      EventMachine::HttpRequest.new(uri).get head: headers
    end

    def post
      EventMachine::HttpRequest.new(uri).post head: headers, body: @params
    end
  end
end
