require 'nervion/client'

module EM
  def self.run &actions
    actions.call
  end

  def self.connect(*args)
  end
end

describe Nervion do
  let(:params)   { stub :params }
  let(:request)  { stub :request }
  let(:callback) { lambda {} }

  it 'creates a sample stream client' do
    Nervion.stub(:get).
      with(Nervion::SAMPLE_ENDPOINT, params, Nervion::Configuration).
      and_return(request)
    Nervion::Client.should_receive(:stream).with(request, &callback)
    Nervion.sample(params, &callback)
  end

  it 'creates a sample stream client without params' do
    Nervion.stub(:get).
      with(Nervion::SAMPLE_ENDPOINT, {}, Nervion::Configuration).
      and_return(request)
    Nervion::Client.should_receive(:stream).with(request, &callback)
    Nervion.sample(&callback)
  end

  it 'creater a filter stream client' do
    Nervion.stub(:post).
      with(Nervion::FILTER_ENDPOINT, params, Nervion::Configuration).
      and_return(request)
    Nervion::Client.should_receive(:stream).with(request, &callback)
    Nervion.filter(params, &callback)
  end
end

describe Nervion::Client do
  subject              { described_class.new }
  let(:request)        { stub :request }
  let(:callbacks)      { stub :callbacks }
  let(:stream_handler) { stub :stream_handler }
  let(:json_parser)    { stub :json_parser }
  let(:http_parser)    { stub :http_parser }

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
