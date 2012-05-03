require 'base64'
require 'openssl'
require_relative 'percent_encoder'

module Nervion
  class OAuthSignature
    include PercentEncoder

    def self.for(http_method, base_url, params, oauth_params, secrets)
      new(http_method, base_url, params, oauth_params, secrets).to_s
    end

    def initialize(http_method, base_url, params, oauth_params, secrets)
      @http_method = http_method
      @base_url = base_url
      @params = params
      @oauth_params = oauth_params
      @secrets = secrets
    end

    def to_s
      Base64.encode64(OpenSSL::HMAC.digest('SHA1', signing_key, base_string)).chomp
    end

    def signing_key
      join @secrets[:consumer_secret], @secrets[:access_token_secret]
    end

    def base_string
      join @http_method.upcase, encode(@base_url), encode(parameter_string)
    end

    def parameter_string
      join signed_params.sort.map { |param_value| encode_pair *param_value }
    end

    def encode_pair(key, value)
      [encode(key.to_s), encode(value.to_s)].join '='
    end

    private

    def join(*param_array)
      param_array.join '&'
    end

    def signed_params
      @params.merge @oauth_params
    end

  end
end
