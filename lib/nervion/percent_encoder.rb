require 'uri'

module Nervion
  module PercentEncoder
    RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

    def self.encode(value)
      URI.escape value.to_s, RESERVED_CHARACTERS
    end
  end
end
