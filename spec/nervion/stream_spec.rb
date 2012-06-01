require 'nervion/stream'

describe Nervion::Stream do
  subject           { described_class.new(:signature, request, callback) }
  let(:request)     { mock(:request) }
  let(:callback)    { mock(:callback) }
  let(:http_parser) { mock(:http_parser) }
  let(:json_parser) { mock.as_null_object }

  before do
    Nervion::HttpParser.stub(:new).and_return(http_parser)
    subject.post_init
  end

  context 'when the stream is initialized' do
    it 'sets up the JSON parser' do
      Yajl::Parser.should_receive(:new).with(symbolize_key: true).
        and_return(json_parser)
      subject.post_init
    end

    it 'sets up the HTTP parser' do
      Yajl::Parser.stub(:new).and_return(json_parser)
      Nervion::HttpParser.should_receive(:new).with(json_parser).
        and_return(http_parser)
      subject.post_init
    end

    it 'sets up the callback' do
      Yajl::Parser.stub(:new).and_return(json_parser)
      json_parser.should_receive(:on_parse_complete=).with(callback)
      subject.post_init
    end
  end

  context 'when the connection is established' do
    before do
      subject.stub(:start_tls)
      subject.stub(:set_comm_inactivity_timeout)
      subject.stub(:send_data)
    end

    it 'sets the innactivity timeout' do
      subject.should_receive(:set_comm_inactivity_timeout)
      subject.connection_completed
    end

    it 'starts TLS encription' do
      subject.should_receive(:start_tls)
      subject.connection_completed
    end

    it 'sends the request' do
      subject.should_receive(:send_data).with(request)
      subject.connection_completed
    end
  end

  context 'when receiving data' do
    it 'appends the received data to the http parser' do
      data = stub
      http_parser.should_receive(:<<).with(data)
      subject.receive_data(data)
    end
  end

  context 'when the response is not successful' do
    it 'should schedule a retry'
  end

  context 'when the conection is unbound' do
    it 'should schedule a retry'
  end
end
