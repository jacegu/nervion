require 'eventmachine'
require 'nervion/client'

describe Nervion::Client do
  subject              { described_class.new }
  let(:request)        { stub :request }
  let(:callbacks)      { stub :callbacks }
  let(:stream_handler) { stub :stream_handler }
  let(:json_parser)    { stub :json_parser }
  let(:http_parser)    { stub :http_parser }

  before(:all) do
    module EventMachine
      class << self
        alias old_run run
        alias old_connect connect
      end
      def self.run; yield; end
      def self.connect(*args); end
    end
  end

  after(:all) do
    module EM
      class << self
        alias run old_run
        alias connect old_connect
      end
    end
  end

  it 'setups the JSON parser' do
    Yajl::Parser.should_receive(:new).with(symbolize_keys: true)
    described_class.new
  end

  it 'setups the HTTP parser' do
    Yajl::Parser.stub(:new).and_return(json_parser)
    Nervion::HttpParser.should_receive(:new).with(json_parser)
    described_class.new
  end

  it 'setups the stream handler' do
    Yajl::Parser.stub(:new).and_return(json_parser)
    Nervion::HttpParser.stub(:new).and_return(http_parser)
    Nervion::StreamHandler.should_receive(:new).
      with(http_parser, json_parser, callbacks)
    subject.stream(request, callbacks)
  end

  it 'fires EventMachine and connects to the Streaming API' do
    Nervion::StreamHandler.stub(:new).and_return(stream_handler)
    EM.should_receive(:connect).with(
      Nervion::STREAM_API_HOST,
      443,
      Nervion::Stream,
      request,
      stream_handler
    )
    subject.stream(request, callbacks)
  end
end
