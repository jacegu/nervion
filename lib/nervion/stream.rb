require 'yajl'
require 'eventmachine'
require_relative 'http_parser'

module Nervion
  class Stream < EM::Connection

    def initialize(*args)
      @request = args[0]
      @handler = args[1]
    end

    def connection_completed
      start_tls
      send_data @request
    end

    def receive_data(data)
      @handler << data
    end

  end
end
