require_relative 'oauth_header'
require_relative 'percent_encoder'

module Nervion
  def self.get(uri, params = {}, oauth_params)
    Get.new uri, params, oauth_params
  end

  def self.post(uri, params = {}, oauth_params)
    Post.new uri, params, oauth_params
  end

  module Request
    attr_reader :params, :oauth_params

    def initialize(uri, params, oauth_params)
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

    def port
      @uri.port
    end

    private

    def request_line
      "#{http_method} #{path} HTTP/1.1"
    end

    def headers
      [ "Host: #{host}", "Authorization: #{OAuthHeader.for(self)}" ]
    end

    def percent_encode(params)
      params.map do |name, value|
        "#{name.to_s}=#{PercentEncoder.encode(value.to_s)}"
      end.join '&'
    end
  end

  class Get
    include Request

    def path
      if params.any?
        "#{super}?#{percent_encode(params)}"
      else
        super
      end
    end

    def to_s
      "#{request_line}\r\n#{headers.join("\r\n")}\r\n\r\n"
    end

    def http_method
      'GET'
    end
  end

  class Post
    include Request

    def to_s
      "#{request_line}\r\n#{headers.join("\r\n")}\r\n\r\n#{body}\r\n"
    end

    def http_method
      'POST'
    end

    private

    def headers
      super << [
        'Content-Type: application/x-www-form-urlencoded',
        "Content-Length: #{body.length}"
      ]
    end

    def body
      percent_encode params
    end
  end
end
