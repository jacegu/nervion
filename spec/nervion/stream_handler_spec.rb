require 'nervion/stream_handler'

describe Nervion::StreamHandler do
  subject           { described_class.new http_parser, json_parser, callbacks }
  let(:http_parser) { mock(:http_parser).as_null_object }
  let(:json_parser) { mock(:json_parser).as_null_object }
  let(:callbacks) do
    {
      status: status_callback,
      http_error: http_error_callback
    }
  end

  let(:status_callback)     { mock :status_callback }
  let(:http_error_callback) { mock(:http_error_callback).as_null_object }

  let(:data) { stub }

  it 'sets up the status received callback' do
    json_parser.should_receive(:on_parse_complete=).with(status_callback)
    described_class.new http_parser, json_parser, callbacks
  end

  it 'appends the received data to the http parser' do
    http_parser.should_receive(:<<).with(data)
    subject << data
  end

  context 'on HTTP error' do
    let(:http_error) { Nervion::HttpError.new(401, 'Unauthorized') }

    before { http_parser.stub(:<<).and_raise http_error }

    it 'calls the callback' do
      begin
        http_error_callback.should_receive(:call).with(401, 'Unauthorized')
        subject << data
      rescue Nervion::HttpError; end
    end

    it 'resets the HTTP parser' do
      begin
        http_parser.should_receive(:reset!)
        subject << data
      rescue Nervion::HttpError; end
    end

    it 're-raises the error' do
      expect { subject << data }.to raise_error(http_error)
    end
  end

end
