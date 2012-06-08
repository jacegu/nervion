require 'eventmachine'
require 'nervion/http_parser'
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
      begin
        @handler << data
      rescue HttpError => error
        @http_error = error
      end
    end

    def unbind
      if http_error
        @handler.handle_http_error http_error
        @scheduler.reconnect_after_http_error_in self
      else
        @handler.handle_network_error
        @scheduler.reconnect_after_network_error_in self
      end
    end

    def http_error_occurred?
      not http_error.nil?
    end

    def retry
      @http_error = nil
      reconnect @request.host, @request.port
    end

  end
end
