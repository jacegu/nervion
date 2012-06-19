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
      EM.should_receive(:add_timer).with  Nervion::HttpWaitCalculator::MIN_WAIT
      subject.reconnect_after_http_error_in stream
    end

    it 'increases the reconnect wait exponentially up to 240 seconds' do
      [10, 20, 40, 80, 160, 240, 240, 240, 240].each do |delay|
        EM.should_receive(:add_timer).with delay
        subject.reconnect_after_http_error_in stream
      end
    end

    it 'raises an error after too many unsuccessful reconnects' do
      limit = described_class::HTTP_ERROR_LIMIT + 1
      expect do
        limit.times { subject.reconnect_after_http_error_in stream }
      end.to raise_error Nervion::TooManyConnectionErrors
    end
  end

  context 'on network errors' do
    it 'tells the stream to reconnect' do
      stream.should_receive(:retry)
      subject.reconnect_after_network_error_in stream
    end

    it 'waits 250ms before reconnecting' do
      EM.should_receive(:add_timer).with Nervion::NetworkWaitCalculator::MIN_WAIT
      subject.reconnect_after_network_error_in stream
    end

    it 'increases the wait after network errors linearly up to 16 seconds' do
      (0.25..16).step(0.25) do |wait|
        EM.should_receive(:add_timer).with wait
        subject.reconnect_after_network_error_in stream
      end
    end

    it 'caps the wait after network errors at 16 seconds' do
      errors_to_cap = (16/0.25).to_i - 1
      errors_to_limit = described_class::NETWORK_ERROR_LIMIT - errors_to_cap - 1
      errors_to_cap.times { subject.reconnect_after_network_error_in stream }
      errors_to_limit.times do
        EM.should_receive(:add_timer).with(16)
        subject.reconnect_after_network_error_in stream
      end
    end

    it 'raises an error after too many unsuccessful reconnects' do
      limit = described_class::NETWORK_ERROR_LIMIT + 1
      expect do
        limit.times { subject.reconnect_after_network_error_in stream }
      end.to raise_error Nervion::TooManyConnectionErrors
    end
  end
end
