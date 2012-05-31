require 'nervion/http_parser'
require 'fixtures/responses'

describe Nervion::HttpParser do
  subject           { described_class.new(json_parser) }
  let(:json_parser) { stub(:json_parser) }

  it 'takes a JSON parser' do
    subject.json_parser.should be json_parser
  end

  context 'with 200 status code' do
    it 'appends the HTTP body to the JSON parser' do
      json_parser.should_receive(:<<).with(BODY_200)
      subject << RESPONSE_200
    end
  end

  context 'with statuses above 200' do
    it 'outputs status code and response body to STDERR' do
      begin
        STDERR.should_receive(:puts).with('401:')
        STDERR.should_receive(:puts).with(BODY_401)
        subject << RESPONSE_401
      rescue; end
    end

    it 'raises an error' do
      expect { subject << RESPONSE_401 }.to raise_error
    end
  end
end

