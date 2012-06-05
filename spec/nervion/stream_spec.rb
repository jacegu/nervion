require 'nervion/stream'

describe Nervion::Stream do
  subject         { described_class.new :signature, request, handler }
  let(:request)   { stub(:request, host: 'host', port: 443) }
  let(:handler)   { mock :handler }
  let(:scheduler) { stub :reconnection_scheduler }

  before(:all) do
    module EventMachine
      class << self
        alias old_add_timer add_timer
        def add_timer(timeout); yield; end
      end
    end
  end

  after(:all) do
    module EventMachine
      class << self
        alias add_timer old_add_timer
      end
    end
  end

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

  context 'HTTP errors' do
    let(:data)  { stub }
    let(:error) { Nervion::Unsuccessful.new(401, 'Unauthorized') }

    before do
      scheduler.stub(:http_error_timeout).and_return(4)
      handler.stub(:<<).and_raise error
    end

    it 'should schedule a retry' do
      EM.should_receive(:add_timer).with(4)
      subject.receive_data(data)
    end

    it 'reconnects when the delay has gone by' do
      subject.should_receive(:reconnect).with('host', 443)
      subject.receive_data(data)
    end
  end

  context 'connection errors' do
    it 'should schedule a retry'
  end
end
