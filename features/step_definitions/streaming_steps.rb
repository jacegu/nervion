TEST_HOST = '0.0.0.0'
TEST_PORT = '9000'

Given /^the Twitter Streaming API is up$/ do
end

Given /^Nervion is connected to it$/ do
  point_client_to_fake_server
end

When /^a status update is sent by Twitter$/ do
  @statuses = []
  Nervion.on_network_error { puts 'error but everything is ok' }
  EM.run do
    EM.start_server(TEST_HOST, TEST_PORT, WorkingStreamingApiDouble)
    EM.add_timer(0.1) { Nervion.sample { |status| @statuses << status } }
    EM.add_timer(0.2) { EM.stop }
  end
end

Then /^Nervion calls the status callback with it$/ do
  @statuses.count.should eq 100
end

When /^an HTTP error occurs$/ do
  Nervion.on_http_error do |status, body|
    @status, @body = status, body
    Nervion.stop
  end

  Nervion.on_network_error { puts 'error but everything is ok' }

  EM.run do
    EM.start_server(TEST_HOST, TEST_PORT, HttpErrorStreamingApiDouble)
    EM.add_timer(0)   { Nervion.sample { |status| @statuses << status } }
    EM.add_timer(0.2) { EM.stop }
  end
end

Then /^Nervion calls the HTTP error callback$/ do
  @status.should eq 401
  @body.should match /Unauthorized/
end

When /^a network error occurs$/ do
  Nervion.on_network_error do
    @network_error_detected = true
    Nervion.stop
  end

  EM.run do
    EM.start_server(TEST_HOST, TEST_PORT, NetworkErrorStreamingApiDouble)
    EM.add_timer(0)   { Nervion.sample { |status| @statuses << status } }
    EM.add_timer(0.2) { EM.stop }
  end
end

Then /^Nervion calls the network error callback$/ do
  @network_error_detected.should be_true
end

def point_client_to_fake_server
  Nervion.send :remove_const, 'STREAM_API_HOST'
  Nervion.send :remove_const, 'STREAM_API_PORT'
  Nervion.const_set 'STREAM_API_HOST', TEST_HOST
  Nervion.const_set 'STREAM_API_PORT', TEST_PORT
end
