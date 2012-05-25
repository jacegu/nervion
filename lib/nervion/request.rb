require 'URI'
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

    def initialize(http_method, uri, params, oauth_params)
      @http_method = http_method
      @uri = uri
      @params = params
      @oauth_params = oauth_params
    end

    def path
      @path ||= URI.parse(@uri).path
    end

    def request
      buffer = ''
      buffer << @http_method.to_s.upcase << ' '
      buffer << path                     << ' '
      buffer << 'HTTP/1.1'               << "\n"
      buffer << 'Authorization:'         << ' '
      buffer << OAuthHeader.for(self)    << "\n"
    end
  end
end
