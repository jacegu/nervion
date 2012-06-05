require 'eventmachine'
require_relative '../lib/nervion/client'

STATUS_COUNT = 100
$statuses = []

class TestClient < Nervion::Client
  def request_test_stream
    stream Nervion.get('http://0.0.0.0:9000/whatever.json', {}), callbacks
  end

  def callbacks
    {
      status: ->(status){ $statuses << status },
      unsuccessful_request: ->(status, body){ STDERR.puts "#{status}: #{body}" }
    }
  end
end

class TwitterStreamDouble < EM::Connection
  STREAM_FILE_PATH = File.join(File.dirname(__FILE__), 'fixtures/stream.txt')
  RESPONSE_OK = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nTransfer-Encoding: chunked\r\n\r\n"

  def post_init
    start_tls
  end

  def receive_data(data)
    send_response_ok
    stream_sample
  end

  def send_response_ok
    send_data RESPONSE_OK
  end

  def stream_sample
    EM::FileStreamer.new(self, STREAM_FILE_PATH, http_chunks: true).callback do
      close_connection_after_writing
    end
  end
end

describe 'Receiving a stream' do
  it 'receives all the statuses' do
    host, port = '0.0.0.0', 9000
    EM.run do
      EM.start_server(host, port, TwitterStreamDouble)
      EM.add_timer(0) { TestClient.new(host, port).request_test_stream }
      EM.add_timer(0.2) { EM.stop }
    end
    $statuses.count.should eq STATUS_COUNT
  end
end
