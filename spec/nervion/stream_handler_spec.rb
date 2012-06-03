require 'nervion/stream_handler'

describe Nervion::StreamHandler do
  subject           { described_class.new http_parser, json_parser, callbacks }
  let(:http_parser) { mock :http_parser }
  let(:json_parser) { mock(:json_parser).as_null_object }
  let(:callbacks) do
    {
      status: status_callback,
      unsuccessful_request: unsuccessful_request_callback
    }
  end

  let(:status_callback)     { mock :status_callback }
  let(:unsuccessful_request_callback) { mock :unsuccessful_request_callback }

  it 'sets up the status received callback' do
    json_parser.should_receive(:on_parse_complete=).with(status_callback)
    described_class.new http_parser, json_parser, callbacks
  end

  context 'handling stream data' do
    let(:data) { stub }

    it 'appends the received data to the http parser' do
      http_parser.should_receive(:<<).with(data)
      subject << data
    end

    it 'handles unsuccessful request errors' do
      status, body = 401, 'Unauthorized'
      error = Nervion::Unsuccessful.new(status, body)
      http_parser.stub(:<<).and_raise error
      unsuccessful_request_callback.should_receive(:call).with(status, body)
      subject << data
    end
  end

end
