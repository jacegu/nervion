require 'nervion/configuration'

describe Nervion::Configuration do

  it 'allows configuration from the top level' do
    Nervion::Configuration.should_receive(:access_key=).with 'access_key'
    Nervion.configure { |config| config.access_key = 'access_key' }
  end

  context 'when it has not been configured' do
    it 'has an empty string as consumer_key' do
      described_class.consumer_key.should eq ''
    end

    it 'has an empty string as consumer secret' do
      described_class.consumer_secret.should eq ''
    end

    it 'has an empty string as access token' do
      described_class.access_token.should eq ''
    end

    it 'has an empty string as access token secret' do
      described_class.access_token_secret.should eq ''
    end
  end

  context 'configuration' do
    it 'can be set with the consumer key' do
      described_class.consumer_key = 'consumer_key'
      described_class.consumer_key.should eq 'consumer_key'
    end

    it 'can be set with the consumer secret' do
      described_class.consumer_secret = 'consumer_secret'
      described_class.consumer_secret.should eq 'consumer_secret'
    end

    it 'can be set with the access token' do
      described_class.access_token = 'access token'
      described_class.access_token.should eq 'access token'
    end

    it 'can be set with the access token secret' do
      described_class.access_token_secret = 'access token secret'
      described_class.access_token_secret.should eq 'access token secret'
    end
  end

  context 'accessing configuration' do
    it 'settings can de accessed as if it was hash' do
      described_class.consumer_secret = 'consumer_secret'
      described_class[:consumer_secret].should eq 'consumer_secret'
      described_class.fetch(:consumer_secret).should eq 'consumer_secret'
    end
  end

end
