require 'nervion/stream'

describe Nervion::Stream do
  subject       { described_class.new :signature, request, handler }
  let(:request) { mock :request }
  let(:handler) { mock :handler }

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

  context 'when the response is not successful' do
    it 'should schedule a retry'
  end

  context 'when the conection is unbound' do
    it 'should schedule a retry'
  end
end
