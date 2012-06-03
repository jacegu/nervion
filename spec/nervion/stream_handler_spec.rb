require 'nervion/stream_handler'

describe Nervion::StreamHandler do
  subject           { described_class.new callbacks}
  let(:http_parser) { mock :http_parser }
  let(:json_parser) { mock(:json_parser).as_null_object }

  let(:callbacks) do
    mock :callbacks,
        status: status_callback,
        unsuccessful_request: unsuccessful_request_callback
  end

  let(:status_callback)     { mock :status_callback }
  let(:unsuccessful_request_callback) { mock :unsuccessful_request_callback }

  before do
    Nervion::HttpParser.stub(:new).and_return(http_parser)
    subject.post_init
  end

  context 'when the stream is initialized' do
    it 'sets up the JSON parser' do
      Yajl::Parser.should_receive(:new).with(symbolize_keys: true).
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
      json_parser.should_receive(:on_parse_complete=).with(status_callback)
      subject.post_init
    end
  end

  context 'handling stream data' do
    let(:data) { stub }

    it 'appends the received data to the http parser' do
      http_parser.should_receive(:<<).with(data)
      subject.receive_data(data)
    end

    it 'handles unsuccessful request errors' do
      status, body = 401, 'Unauthorized'
      error = Nervion::Unsuccessful.new(status, body)
      http_parser.stub(:<<).and_raise error
      unsuccessful_request_callback.should_receive(:call).with(status, body)
      subject.receive_data(data)
    end
  end



end
