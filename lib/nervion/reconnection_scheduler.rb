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
      @http_errors.notify_error
      delay = @http_wait_calculator.wait_for(@http_errors.count)
      schedule_reconnect stream, delay
    end

    def reconnect_after_network_error_in(stream)
      @network_errors.notify_error
      delay = @network_wait_calculator.wait_for(@network_errors.count)
      schedule_reconnect stream, delay
    end

    private

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
      raise TooManyConnectionErrors if @count >= @limit
    end
  end

  class WaitCalculator
    def initialize(max_wait, &calculator)
      @max_wait = max_wait
      @calculator = calculator
    end

    def wait_for(error_count)
      [@calculator.call(error_count), @max_wait].min
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
