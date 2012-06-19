$: << File.join(File.dirname(__FILE__), '..', '..', 'spec')

require 'fixtures/responses'
STREAM_FILE_PATH = File.join(File.dirname(__FILE__), '..', '..', 'spec', 'fixtures/stream.txt')

class WorkingStreamingApiDouble < EM::Connection
  def post_init
    start_tls
  end

  def receive_data(data)
    send_response_ok
    stream_sample
  end

  def send_response_ok
    send_data RESPONSE_200_HEADERS
  end

  def stream_sample
    EM::FileStreamer.new(self, STREAM_FILE_PATH, http_chunks: true).callback do
      close_connection_after_writing
    end
  end
end

class HttpErrorStreamingApiDouble < EM::Connection
  def post_init
    start_tls
  end

  def receive_data(data)
    send_data RESPONSE_401
    close_connection_after_writing
  end
end

class NetworkErrorStreamingApiDouble < EM::Connection
  def post_init
    start_tls
  end

  def receive_data(data)
    close_connection
  end
end
