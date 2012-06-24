module Nervion

  # Allows to configure Nervion.
  #
  # @yieldparam [Configuration] config the configuration object.
  def self.configure
    yield Configuration
  end

  class Configuration
    UNCONFIGURED_SETTING = ''

    # Configures the consumer key
    #
    # @param [String] consumer_key the consumer key
    def self.consumer_key=(consumer_key)
      @consumer_key = consumer_key
    end

    def self.consumer_key
      @consumer_key || UNCONFIGURED_SETTING
    end

    # Configures the consumer secret
    #
    # @param [String] consumer_secret the consumer secret
    def self.consumer_secret=(consumer_secret)
      @consumer_secret = consumer_secret
    end

    def self.consumer_secret
      @consumer_secret || UNCONFIGURED_SETTING
    end

    # Configures the access token
    #
    # @param [String] access_token the access token
    def self.access_token=(access_token)
      @access_token = access_token
    end

    def self.access_token
      @access_token || UNCONFIGURED_SETTING
    end

    # Configures the access token secret
    #
    # @param [String] access_token_secret the access token secret
    def self.access_token_secret=(access_token_secret)
      @access_token_secret = access_token_secret
    end

    def self.access_token_secret
      @access_token_secret || UNCONFIGURED_SETTING
    end

    def self.[](setting)
      fetch setting
    end

    def self.fetch(setting)
      send setting.to_sym
    end
  end
end
