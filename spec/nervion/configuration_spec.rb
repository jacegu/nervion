require 'nervion/configuration'

describe Nervion::Configuration do
  context 'when it has not being configured' do
    it 'has an empty string as consumer_key' do
      subject.consumer_key.should eq ''
    end

    it 'has an empty string as consumer secret' do
      subject.consumer_secret.should eq ''
    end

    it 'has an empty string as access token' do
      subject.access_token.should eq ''
    end

    it 'has an empty string as access token secret' do
      subject.access_token_secret.should eq ''
    end
  end

  context 'configuration' do
    it 'can be set with the consumer key' do
      subject.consumer_key = 'consumer_key'
      subject.consumer_key.should eq 'consumer_key'
    end

    it 'can be set with the consumer secret' do
      subject.consumer_secret = 'consumer_secret'
      subject.consumer_secret.should eq 'consumer_secret'
    end

    it 'can be set with the access token' do
      subject.access_token = 'access token'
      subject.access_token.should eq 'access token'
    end

    it 'can be set with the access token secret' do
      subject.access_token_secret = 'access token secret'
      subject.access_token_secret.should eq 'access token secret'
    end
  end

  it 'can provide configuration settings as if it was hash' do
    subject[:consumer_key].should eq ''
    subject.consumer_secret = 'consumer_secret'
    subject.fetch(:consumer_secret).should eq 'consumer_secret'
  end
end
