module Nervion
  class Configuration
    UNCONFIGURED_SETTING = ''

    attr_writer :consumer_key

    def consumer_key
      @consumer_key || UNCONFIGURED_SETTING
    end

    attr_writer :consumer_secret

    def consumer_secret
      @consumer_secret || UNCONFIGURED_SETTING
    end

    attr_writer :access_token

    def access_token
      @access_token || UNCONFIGURED_SETTING
    end

    attr_writer :access_token_secret

    def access_token_secret
      @access_token_secret || UNCONFIGURED_SETTING
    end

    def [](setting)
      fetch setting
    end

    def fetch(setting)
      send setting.to_sym
    end
  end
end
