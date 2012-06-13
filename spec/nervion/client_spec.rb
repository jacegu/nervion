require 'eventmachine'
require 'nervion/client'

describe 'Nervion Client DSL' do
end

describe Nervion::Client do
  subject              { described_class.new }
  let(:request)        { stub :request }
  let(:callbacks)      { stub :callbacks }
  let(:stream_handler) { stub :stream_handler }

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

  it 'setups the stream handler' do
    Nervion::StreamHandler.should_receive(:new).with(callbacks)
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

  it 'stops the client' do
    Nervion::StreamHandler.stub(:new).and_return(stream_handler)
    stream_handler.should_receive(:close_stream).ordered
    EM.should_receive(:stop).ordered
    subject.stream(request, callbacks)
    subject.stop
  end
end
