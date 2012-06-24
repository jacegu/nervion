require 'nervion/stream_handler'

describe Nervion::StreamHandler do
  subject           { described_class.new callbacks }
  let(:http_parser) { mock(:http_parser).as_null_object }
  let(:json_parser) { mock(:json_parser).as_null_object }

  let(:callbacks) do
    {
      status:        status_callback,
      http_error:    http_error_callback,
      network_error: network_error_callback
    }
  end

  let(:status_callback)        { mock :status_callback }
  let(:http_error_callback)    { mock(:http_error_callback).as_null_object }
  let(:network_error_callback) { mock(:network_error_callback).as_null_object }

  before do
    Yajl::Parser.stub(:new).with(symbolize_keys: true).and_return(json_parser)
    Nervion::HttpParser.stub(:new).with(json_parser).and_return(http_parser)
  end

  it 'sets up the status received callback' do
    json_parser.should_receive(:on_parse_complete=).with(status_callback)
    described_class.new callbacks
  end

  it 'appends the received data to the http parser' do
    data = stub
    http_parser.should_receive(:<<).with(data)
    subject << data
  end

  context 'handling HTTP errors' do
    let(:http_error) { stub(:http_error, status: 401, body: 'Unauthorized') }

    it 'resets the HTTP parser' do
      http_parser.should_receive(:reset!)
      subject.handle_http_error http_error
    end

    it 'calls the HTTP error callback' do
      http_error_callback.should_receive(:call).with(401, 'Unauthorized')
      subject.handle_http_error http_error
    end
  end

  context 'handling network errors' do
    it 'resets the HTTP parser' do
      http_parser.should_receive(:reset!)
      subject.handle_network_error
    end

    it 'calls the network error callback' do
      network_error_callback.should_receive(:call)
      subject.handle_network_error
    end
  end
end
