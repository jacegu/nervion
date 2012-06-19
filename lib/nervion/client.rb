require 'nervion/configuration'
require 'nervion/request'
require 'nervion/stream'
require 'nervion/stream_handler'

module Nervion
  class Client
    def initialize(host, port)
      @host = host
      @port = port
    end

    def stream(request, callbacks)
      @stream_handler = StreamHandler.new(callbacks)
      EM.run { EM.connect @host, @port, Stream, request, @stream_handler }
    end

    def stop
      @stream_handler.close_stream
      EM.stop
    end
  end
end
