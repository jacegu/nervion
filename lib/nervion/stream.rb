require 'eventmachine'
require 'nervion/http_parser'
require 'nervion/reconnection_scheduler'

module Nervion
  class Stream < EM::Connection

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
      rescue Unsuccessful
        @scheduler.reconnect_after_http_error_in self
      end
    end

    def retry
      reconnect @request.host, @request.port
    end

  end
end
