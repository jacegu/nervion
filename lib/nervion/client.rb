require 'nervion/stream'
require 'nervion/stream_handler'

module Nervion
  class Client
    def initialize(host, port)
      @host = host
      @port = port
    end

    def stream(request, callbacks)
      handler = StreamHandler.new(callbacks)
      EM.run { @stream = EM.connect @host, @port, Stream, request, handler }
    end

    def stop
      close_stream
      EM.stop
    end

    def close_stream
      @stream.close
    end
  end
end
