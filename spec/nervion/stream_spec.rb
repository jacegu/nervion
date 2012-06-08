require 'nervion/stream'

describe Nervion::Stream do
  subject         { described_class.new :signature, request, handler }
  let(:request)   { stub(:request, host: 'host', port: 443) }
  let(:handler)   { mock :handler }
  let(:scheduler) { stub :reconnection_scheduler }

  before { Nervion::ReconnectionScheduler.stub(:new).and_return(scheduler) }

  context 'when the connection is established' do
    it 'starts TLS encription' do
      subject.stub(:send_data)
      subject.should_receive(:start_tls)
      subject.connection_completed
    end

    it 'sends the request' do
      subject.stub(:start_tls)
      subject.should_receive(:send_data).with(request)
      subject.connection_completed
    end
  end

  it 'provides the received data to the stream handler' do
    data = stub
    handler.should_receive(:<<).with(data)
    subject.receive_data(data)
  end

  it 'knows where to reconnect to' do
    subject.should_receive(:reconnect).with('host', 443)
    subject.retry
  end

  it 'reconnects on HTTP errors' do
    data, error = stub, Nervion::Unsuccessful.new(401, 'Unauthorized')
    handler.stub(:<<).and_raise error
    scheduler.should_receive(:reconnect_after_http_error_in).with(subject)
    subject.receive_data(data)
  end

  context 'connection errors' do
    it 'should schedule a retry'
  end
end
