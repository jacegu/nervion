require 'uri'

module Nervion
  module PercentEncoder
    OAUTH_RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

    def encode(value)
      URI.escape value.to_s, OAUTH_RESERVED_CHARACTERS
    end
  end
end
