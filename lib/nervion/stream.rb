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
      @reconnection_scheduler = ReconnectionScheduler.new
    end

    def connection_completed
      start_tls
      send_data @request
    end

    def receive_data(data)
      begin
        @handler << data
      rescue Unsuccessful
        delay = @reconnection_scheduler.http_error_timeout
        EM.add_timer(delay) { reconnect(@request.host, @request.port) }
      end
    end

  end
end
