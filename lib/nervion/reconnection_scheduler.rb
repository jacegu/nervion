require 'eventmachine'

module Nervion
  class ReconnectionScheduler
    MIN_HTTP_ERROR_TIMEOUT = 10
    MAX_HTTP_ERROR_TIMEOUT = 240

    RECONNECTION_LIMIT = 10

    TOO_MANY_HTTP_ERRORS = "There have been too many HTTP errors. This is probably a client configuration issue that has to be taken care of."

    def initialize
      @http_error_count = 0
      @http_error_timeout = MIN_HTTP_ERROR_TIMEOUT / 2
    end

    def reconnect_after_http_error_in(stream)
      @http_error_count += 1
      check_http_error_count
      schedule_reconnect stream, delay_after_http_error
    end

    def reconnect_after_network_error_in(stream)
      schedule_reconnect stream, 0.25
    end

    private

    def check_http_error_count
      raise ReconnectError, TOO_MANY_HTTP_ERRORS if too_many_reconnects?
    end

    def schedule_reconnect(stream, seconds)
      EM.add_timer(seconds) { stream.retry }
    end

    def delay_after_http_error
      [@http_error_timeout *= 2, MAX_HTTP_ERROR_TIMEOUT].min
    end

    def too_many_reconnects?
      @http_error_count >= RECONNECTION_LIMIT
    end
  end

  class ReconnectError < Exception
  end
end
