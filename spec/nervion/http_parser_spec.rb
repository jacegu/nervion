require 'nervion/http_parser'
require 'fixtures/responses'

describe Nervion::HttpParser do
  subject           { described_class.new(json_parser) }
  let(:json_parser) { stub(:json_parser).as_null_object }

  it 'takes a JSON parser' do
    subject.json_parser.should be json_parser
  end

  it 'can be reset' do
    subject << RESPONSE_200
    subject.reset!
    expect { subject << RESPONSE_200 }.not_to raise_error Http::Parser::Error
  end

  it 'parses response body if the response status is 200' do
    json_parser.should_receive(:<<).with(BODY_200)
    subject << RESPONSE_200
  end

  it 'raises an error if the response status is above 200' do
    expect { subject << RESPONSE_401 }.to raise_error Nervion::HttpError
  end
end
