require 'nervion/reconnection_scheduler'

describe Nervion::ReconnectionScheduler do
  let(:stream) { stub(:connection).as_null_object }

  before(:all) do
    module EventMachine
      class << self
        alias old_add_timer add_timer
        def add_timer(timeout); yield; end
      end
    end
  end

  after(:all) do
    module EventMachine
      class << self
        alias add_timer old_add_timer
      end
    end
  end

  context 'on HTTP errors' do
    it 'tells the stream to reconnect' do
      stream.should_receive(:retry)
      subject.reconnect_after_http_error_in stream
    end

    it 'waits 10 seconds before reconnecting' do
      EM.should_receive(:add_timer).with described_class::MIN_HTTP_TIMEOUT
      subject.reconnect_after_http_error_in stream
    end

    it 'increases the reconnect wait exponentially up to 240 seconds' do
      [10, 20, 40, 80, 160, 240, 240, 240, 240].each do |delay|
        EM.should_receive(:add_timer).with delay
        subject.reconnect_after_http_error_in stream
      end
    end

    it 'raises a MaximumReconnectAttempts error' do
      limit = described_class::RECONNECTION_LIMIT + 1
      expect do
        limit.times { subject.reconnect_after_http_error_in stream }
      end.to raise_error Nervion::ReconnectError
    end
  end

end
