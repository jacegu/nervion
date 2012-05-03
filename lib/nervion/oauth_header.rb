require 'date'
require 'digest/md5'
require_relative 'oauth_signature'
require_relative 'oauth_settings'
require_relative  'percent_encoder'

module Nervion
  class OAuthHeader
    include PercentEncoder

    attr_reader :http_method, :base_url, :params

    def self.for(request)
      new(request.http_method, request.uri, request.params).to_s
    end

    def initialize(http_method, base_url, params)
      @http_method, @base_url, @params = http_method, base_url, params
    end

    PARAMETERS_INCLUDED = %w{ oauth_consumer_key
                              oauth_nonce
                              oauth_signature
                              oauth_signature_method
                              oauth_timestamp
                              oauth_token
                              oauth_version }

    def to_s
      'OAuth ' << PARAMETERS_INCLUDED.map do |param|
        method_name = param.gsub /^oauth_/, ''
        "#{param}=\"#{encode(send(method_name))}\""
      end.join(', ')
    end

    def consumer_key
      OAuthSettings.consumer_key
    end

    def consumer_secret
      OAuthSettings.consumer_secret
    end

    def token
      OAuthSettings.access_token
    end

    def token_secret
      OAuthSettings.access_token_secret
    end

    def nonce
      Digest::MD5.hexdigest "#{consumer_key}#{token}#{timestamp}"
    end

    def timestamp
      Time.now.to_i.to_s
    end

    def signature_method
      'HMAC-SHA1'
    end

    def version
      '1.0'
    end

    def signature
      OAuthSignature.for http_method, base_url, params, oauth_info, secrets
    end

    def oauth_info
      {
        oauth_consumer_key: consumer_key,
        oauth_nonce: nonce,
        oauth_signature_method: signature_method,
        oauth_timestamp: timestamp,
        oauth_token: token,
        oauth_version: version
      }
    end

    def secrets
      {
        consumer_secret: consumer_secret,
        access_token_secret: token_secret
      }
    end

  end
end
