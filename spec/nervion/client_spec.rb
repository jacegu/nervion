require 'eventmachine'
require 'nervion/client'

describe Nervion::Client do
  subject              { described_class.new('http://twitter.com', 443) }
  let(:request)        { stub :request }
  let(:callbacks)      { stub :callbacks }
  let(:stream)         { mock :stream }
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

  before do
    Nervion::StreamHandler.stub(:new).with(callbacks).and_return(stream_handler)
  end

  it 'starts treaming' do
    EM.should_receive(:connect).with(
      'http://twitter.com',
      443,
      Nervion::Stream,
      request,
      stream_handler
    )
    subject.stream(request, callbacks)
  end

  it 'stops streaming' do
    EM.stub(:connect).and_return(stream)
    stream.should_receive(:close).ordered
    EM.should_receive(:stop).ordered
    subject.stream(request, callbacks)
    subject.stop
  end
end
