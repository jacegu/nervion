require 'eventmachine'
require 'nervion/client'
require 'fixtures/responses'

STATUS_COUNT = 100
STREAM_FILE_PATH = 'fixtures/stream.txt'

$statuses = []
$http_error_status = ''
$http_error_body = ''
$network_error_occurred = false

class TestClient < Nervion::Client
  def request_test_stream
    stream Nervion.get('http://0.0.0.0:9000/whatever.json', {}), callbacks
  end

  def callbacks
    {
      status: ->(status){ $statuses << status },
      http_error: ->(status, body) do
        $http_error_status, $http_error_body = status, body
        stop
      end,
      network_error: -> do
        $network_error_occurred = true
        stop
      end
    }
  end
end

class TwitterStreamDouble < EM::Connection
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

class TwitterStreamHttpError < TwitterStreamDouble
  def receive_data(data)
    send_data RESPONSE_401
    close_connection_after_writing
  end
end

class TwitterStreamNetworkError < TwitterStreamDouble
  def receive_data(data)
    close_connection
  end
end

describe 'Receiving a stream' do
  it 'receives all the statuses' do
    run_server_and_client TwitterStreamDouble
    $statuses.count.should eq STATUS_COUNT
  end

  it 'calls callback on HTTP errors' do
    run_server_and_client TwitterStreamHttpError
    $http_error_status.should eq 401
    $http_error_body.should match /Unauthorized/
  end

  it 'calls callback on Network errors' do
    run_server_and_client TwitterStreamNetworkError
    $network_error_occurred.should be_true
  end

  def run_server_and_client(handler)
    host, port = '0.0.0.0', 9000
    EM.run do
      EM.start_server(host, port, handler)
      EM.add_timer(0) { TestClient.new(host, port).request_test_stream }
      EM.add_timer(0.2) { EM.stop }
    end
  end
end
