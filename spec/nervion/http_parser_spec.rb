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
    it 'resets the HTTP parsing' do
      begin
        fresh_parser = stub(:fresh_parser).as_null_object
        subject.stub(:setup_http_parser).and_return(fresh_parser)
        subject << RESPONSE_401
        subject.http_parser.should be fresh_parser
      rescue Nervion::Unsuccessful; end
    end

    it 'raises a Nervion::Unsuccessful error' do
      expect { subject << RESPONSE_401 }.to raise_error Nervion::Unsuccessful
    end
  end
end
