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

    attr_reader :http_method, :params, :oauth_params

    def initialize(http_method, uri, params = {}, oauth_params)
      @http_method = http_method.to_s.upcase
      @uri = URI.parse(uri)
      @params = params
      @oauth_params = oauth_params
    end

    def uri
      @uri.to_s
    end

    def path
      @uri.request_uri
    end

    def host
      @uri.host
    end

    def to_s
      buffer = ''
      buffer << @http_method           << ' '
      buffer << path                   << ' '
      buffer << 'HTTP/1.1'             << "\r\n"
      buffer << 'Host: ' << host       << "\r\n"
      buffer << 'Authorization:'       << ' '
      buffer << OAuthHeader.for(self)  << "\r\n\r\n"
    end
  end
end
