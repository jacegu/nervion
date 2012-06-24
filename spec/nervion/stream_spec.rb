require 'nervion/stream'

describe Nervion::Stream do
  subject          { described_class.new :signature, request, handler }
  let(:request)    { stub(:request, host: 'host', port: 443) }
  let(:handler)    { mock :handler }
  let(:scheduler)  { mock :reconnection_scheduler }
  let(:http_error) { Nervion::HttpError.new(401, 'Unauthorized') }

  before { Nervion::ReconnectionScheduler.stub(:new).and_return(scheduler) }

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

  it 'handles received data' do
    data = stub
    handler.should_receive(:<<).with(data)
    subject.receive_data(data)
  end

  it 'registers HTTP errors' do
    handler.stub(:<<).and_raise http_error
    subject.receive_data('some random data')
    subject.http_error.should be http_error
  end

  it 'clears HTTP errors before retries' do
    subject.stub(:reconnect)
    handler.stub(:<<).and_raise http_error
    subject.receive_data('some random data')
    subject.retry
    subject.http_error.should be_nil
  end

  it 'knows how to retry' do
    subject.should_receive(:reconnect).with('host', 443)
    subject.retry
  end

  it 'can be closed' do
    subject.close_requested?.should be_false
    subject.close
    subject.close_requested?.should be_true
  end

  context 'on unbound connections' do
    context 'due to HTTP errors' do
      before do
        subject.stub(:http_error).and_return(http_error)
      end

      it 'notifies the error' do
        handler.should_receive(:handle_http_error).with(http_error)
        scheduler.stub(:reconnect_after_http_error_in)
        subject.unbind
      end

      it 'schedules a retry' do
        handler.stub(:handle_http_error)
        scheduler.should_receive(:reconnect_after_http_error_in).with(subject)
        subject.unbind
      end
    end

    context 'due to network errors' do
      it 'notifies the error' do
        handler.should_receive(:handle_network_error)
        scheduler.stub(:reconnect_after_network_error_in)
        subject.unbind
      end

      it 'schedules a retry' do
        handler.stub(:handle_network_error)
        scheduler.should_receive(:reconnect_after_network_error_in).with(subject)
        subject.unbind
      end
    end

    context 'due to a request to close the stream' do
      it 'lets the stream to be closed' do
        handler.should_not_receive(:handle_http_error)
        handler.should_not_receive(:handle_network_error)
        scheduler.should_not_receive(:reconnect_after_http_error_in)
        scheduler.should_not_receive(:reconnect_after_network_error_in)
        subject.close
        subject.unbind
      end
    end
  end

end
