module Nervion

  def self.configure
    yield Configuration
  end

  class Configuration
    UNCONFIGURED_SETTING = ''

    def self.consumer_key=(consumer_key)
      @consumer_key = consumer_key
    end

    def self.consumer_key
      @consumer_key || UNCONFIGURED_SETTING
    end

    def self.consumer_secret=(consumer_secret)
      @consumer_secret = consumer_secret
    end

    def self.consumer_secret
      @consumer_secret || UNCONFIGURED_SETTING
    end

    def self.access_token=(access_token)
      @access_token = access_token
    end

    def self.access_token
      @access_token || UNCONFIGURED_SETTING
    end

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
