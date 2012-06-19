module Nervion
  class CallbackTable

    def initialize
      @callbacks = {
        http_error: http_error_callback,
        network_error: empty_callback
      }
    end

    def []=(name, code)
      @callbacks[name] = code
    end

    def [](name)
      @callbacks[name]
    end

    private

    def empty_callback
      lambda { }
    end

    def http_error_callback
      ->(status, body) { STDERR.puts "#{status}:\n#{body}" }
    end

  end
end
