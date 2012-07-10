require 'eventmachine'
require 'nervion/stream_parser'
require 'nervion/reconnection_scheduler'

module Nervion
  class Stream < EM::Connection

    attr_reader :http_error

    def initialize(*args)
      @request = args[0]
      @handler = args[1]
    end

    def post_init
      @scheduler = ReconnectionScheduler.new
    end

    def connection_completed
      start_tls
      send_data @request
    end

    def receive_data(data)
      @handler << data
    rescue HttpError => error
      @http_error = error
    end

    def retry
      @http_error = nil
      reconnect @request.host, @request.port
    end

    def unbind
      handle_closed_stream unless close_requested?
    end

    def http_error_occurred?
      not http_error.nil?
    end

    def close_requested?
      @close_stream ||= false
    end

    def close
      @close_stream = true
      close_connection
    end

    private

    def handle_closed_stream
      if http_error_occurred?
        handle_http_error_and_retry
      else
        handle_network_error_and_retry
      end
    end

    def handle_http_error_and_retry
      @handler.handle_http_error http_error
      @scheduler.reconnect_after_http_error_in self
    end

    def handle_network_error_and_retry
      @handler.handle_network_error
      @scheduler.reconnect_after_network_error_in self
    end

  end
end
