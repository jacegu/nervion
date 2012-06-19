TEST_HOST = '0.0.0.0'
TEST_PORT = '9000'

def point_client_to_fake_server
  Nervion.send :remove_const, 'STREAM_API_HOST'
  Nervion.send :remove_const, 'STREAM_API_PORT'
  Nervion.const_set 'STREAM_API_HOST', TEST_HOST
  Nervion.const_set 'STREAM_API_PORT', TEST_PORT
end

def test_client_with(server_version)
  EM.run do
    EM.start_server(TEST_HOST, TEST_PORT, server_version)
    EM.add_timer(0)   { Nervion.sample { |status| @statuses << status } }
    EM.add_timer(0.1) { EM.stop }
  end
end

Given /^Nervion is connected to Twitter Streaming API$/ do
  point_client_to_fake_server
end

When /^a status update is sent by Twitter$/ do
  @statuses = []
  test_client_with WorkingStreamingApiDouble
end

When /^an HTTP error occurs$/ do
  Nervion.on_http_error do |status, body|
    @status, @body = status, body
    Nervion.stop
  end
  test_client_with HttpErrorStreamingApiDouble
end

When /^a network error occurs$/ do
  Nervion.on_network_error do
    @network_error_detected = true
    Nervion.stop
  end
  test_client_with NetworkErrorStreamingApiDouble
end

Then /^Nervion calls the status callback with it$/ do
  @statuses.count.should eq 100
end

Then /^Nervion calls the HTTP error callback$/ do
  @status.should eq 401
  @body.should match /Unauthorized/
end

Then /^Nervion calls the network error callback$/ do
  @network_error_detected.should be_true
end
