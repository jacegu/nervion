require 'eventmachine'

module Nervion
  class ReconnectionScheduler
    HTTP_ERROR_LIMIT    = 10
    NETWORK_ERROR_LIMIT = 65

    def initialize
      @http_errors = ErrorCounter.new(HTTP_ERROR_LIMIT)
      @network_errors = ErrorCounter.new(NETWORK_ERROR_LIMIT)
      @http_wait_calculator = HttpWaitCalculator.new
      @network_wait_calculator = NetworkWaitCalculator.new
    end

    def reconnect_after_http_error_in(stream)
      reconnect_after_error stream, @http_errors, @http_wait_calculator
    end

    def reconnect_after_network_error_in(stream)
      reconnect_after_error stream, @network_errors, @network_wait_calculator
    end

    private

    def reconnect_after_error(stream, errors, wait_calculator)
      errors.notify_error
      schedule_reconnect stream, wait_calculator.wait_after(errors.count)
    end

    def schedule_reconnect(stream, seconds)
      EM.add_timer(seconds) { stream.retry }
    end
  end

  class ErrorCounter
    attr_reader :count

    def initialize(limit)
      @count = 0
      @limit = limit
    end

    def notify_error
      @count += 1
      raise TooManyConnectionErrors if too_many_errors?
    end

    private

    def too_many_errors?
      @count >= @limit
    end
  end

  class WaitCalculator
    def initialize(max_wait, &calculator)
      @max_wait = max_wait
      @calculator = calculator
    end

    def wait_after(error_count)
      cap_wait @max_wait, calculate_wait_after(error_count)
    end

    private

    def cap_wait(cap_value, current_wait)
      [current_wait, cap_value].min
    end

    def calculate_wait_after(error_count)
      @calculator.call(error_count)
    end
  end

  class HttpWaitCalculator < WaitCalculator
    MIN_WAIT = 10
    MAX_WAIT = 240

    def initialize
      super(MAX_WAIT) { |error_count| MIN_WAIT * 2**(error_count - 1) }
    end
  end

  class NetworkWaitCalculator < WaitCalculator
    MIN_WAIT = 0.25
    MAX_WAIT = 16

    def initialize
      super(MAX_WAIT) { |error_count| MIN_WAIT * error_count }
    end
  end

  class TooManyConnectionErrors < Exception
  end
end
