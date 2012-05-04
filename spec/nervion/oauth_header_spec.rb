require 'nervion/oauth_header'

describe Nervion::OAuthHeader do
  subject { described_class.new http_method, base_url, params, oauth_params }

  let(:http_method)         { 'post' }
  let(:base_url)            { 'https://api.twitter.com/1/statuses/update.json' }
  let(:params)              { Hash[include_entities: true, status: '@patheleven'] }
  let(:consumer_key)        { 'xvz1evFS4wEEPTGEFPHBog' }
  let(:consumer_secret)     { 'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw' }
  let(:access_token)        { 'GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb' }
  let(:access_token_secret) { 'LswwdoUaIvS8ltyTth4J50vUPVVHtR2YPi5kE' }
  let(:oauth_params) do
    {
      consumer_key: consumer_key,
      consumer_secret: consumer_secret,
      access_token: access_token,
      access_token_secret: access_token_secret
    }
  end

  it 'takes the consumer key from oauth params' do
    subject.consumer_key.should be consumer_key
  end

  it 'takes the consumer secret from oauth params' do
    subject.consumer_secret.should be consumer_secret
  end

  it 'takes the access token from oauth params' do
    subject.token.should be access_token
  end

  it 'takes the access token secret from oauth params' do
    subject.token_secret.should be access_token_secret
  end

  it 'nonce is md5 of a string formed by consumer key, token and timestamp' do
    nonce, timestamp = stub, 123456878
    subject.stub(:timestamp).and_return timestamp
    string = "#{consumer_key}#{access_token}#{timestamp}"
    Digest::MD5.stub(:hexdigest).with(string).and_return nonce
    subject.nonce.should be nonce
  end

  it 'timestamp is seconds since epoch as string' do
    seconds_since_epoch = stub(to_s: 'timestamp')
    now = stub(to_i: seconds_since_epoch)
    Time.stub(:now).and_return now
    subject.timestamp.should eq 'timestamp'
  end

  it 'signature method is HMAC-SHA1' do
    subject.signature_method.should eq 'HMAC-SHA1'
  end

  it 'version is 1.0' do
    subject.version.should eq '1.0'
  end

  it 'provides a hash with the info required to create a signature' do
    nonce, timestamp = stub(:nonce), stub(:timestamp)
    subject.stub(:nonce).and_return nonce
    subject.stub(:timestamp).and_return timestamp
    oauth_info = {
      oauth_consumer_key: consumer_key,
      oauth_nonce: nonce,
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: timestamp,
      oauth_token: access_token,
      oauth_version: '1.0'
    }
    subject.oauth_info.should eq oauth_info
  end

  it 'provides a hash with the consumer secret and token secret' do
    expected_secret_hash = {
      consumer_secret: consumer_secret,
      access_token_secret: access_token_secret
    }
    subject.secrets.should eq expected_secret_hash
  end

  it 'creates the signature' do
    signature, oauth_info = stub(:signature), stub(:oauth_info)
    subject.stub(:oauth_info).and_return(oauth_info)
    secrets = {
      consumer_secret: consumer_secret,
      access_token_secret: access_token_secret
    }
    Nervion::OAuthSignature.stub(:for).
      with(http_method, base_url, params, oauth_info, secrets).
      and_return signature
    subject.signature.should be signature
  end

  it 'generates the authorization header value' do
    subject.stub(:nonce).and_return 'nonce'
    subject.stub(:timestamp).and_return 'timestamp'
    subject.stub(:signature).and_return 'signature'

    expected_header = %Q{OAuth oauth_consumer_key="#{consumer_key}", oauth_nonce="nonce", oauth_signature="signature", oauth_signature_method="HMAC-SHA1", oauth_timestamp="timestamp", oauth_token="#{access_token}", oauth_version="1.0"}

    subject.to_s.should eq expected_header
  end

  it 'generates the header value for a paticular request' do
    oauth_headers = stub :oauth_headers, to_s: 'OAuth oauth_params="value"'
    Nervion::OAuthHeader.stub(:new).
      with(http_method, base_url, params, oauth_params).and_return oauth_headers
    request = stub :request, http_method: http_method, uri: base_url,
                             params: params, oauth_params: oauth_params
    described_class.for(request).should eq 'OAuth oauth_params="value"'
  end
end
