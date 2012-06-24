require 'nervion/stream_parser'
require 'fixtures/responses'

describe Nervion::StreamParser do
  subject           { described_class.new(json_parser: json_parser) }
  let(:json_parser) { stub(:json_parser).as_null_object }

  it 'takes a JSON parser' do
    subject.json_parser.should be json_parser
  end

  it 'uses Http::Parser as the default HTTP parser' do
    http_parser = stub(:http_parser).as_null_object
    Http::Parser.stub(:new).and_return(http_parser)
    described_class.new.http_parser.should be http_parser
  end

  it 'uses Yajl with symbolized keys as the default JSON parser' do
    yajl_parser = stub(:yajl_parser)
    Yajl::Parser.stub(:new).with(symbolize_keys: true).and_return(yajl_parser)
    described_class.new.json_parser.should be yajl_parser
  end

  it 'can be set up with a JSON parse complete callback' do
    callback = lambda {}
    json_parser.should_receive(:on_parse_complete=).with callback
    subject.on_json_parsed = callback
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
