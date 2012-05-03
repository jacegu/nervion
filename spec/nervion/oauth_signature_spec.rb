require 'nervion/oauth_signature'

describe Nervion::OAuthSignature do
  subject { described_class.new http_method, base_url, params, oauth_params, secrets }

  let(:http_method) { 'post' }
  let(:base_url)    { 'https://api.twitter.com/1/statuses/update.json' }
  let(:params) do
    {
      include_entities: true,
      status: 'Hello Ladies + Gentlemen, a signed OAuth request!'
    }
  end
  let(:oauth_params) do
    {
      oauth_consumer_key:  'xvz1evFS4wEEPTGEFPHBog',
      oauth_nonce: 'kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg',
      oauth_signature_method: 'HMAC-SHA1',
      oauth_timestamp: '1318622958',
      oauth_token: '370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb',
      oauth_version: '1.0',
    }
  end
  let(:secrets) do
    {
      consumer_secret: 'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw',
      access_token_secret: 'LswwdoUaIvS8ltyTth4J50vUPVVHtR2YPi5kE'
    }
  end

  it 'percent encodes key and value and joins the result with a "="' do
    subject.stub(:encode).with('include_entities').and_return 'include_entities'
    subject.stub(:encode).with('true').and_return 'true'
    subject.encode_pair(:include_entities, true).should eq 'include_entities=true'
  end

  it 'provides the parameter string' do
    expected_parameter_string = %q{include_entities=true&oauth_consumer_key=xvz1evFS4wEEPTGEFPHBog&oauth_nonce=kYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg&oauth_signature_method=HMAC-SHA1&oauth_timestamp=1318622958&oauth_token=370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb&oauth_version=1.0&status=Hello%20Ladies%20%2B%20Gentlemen%2C%20a%20signed%20OAuth%20request%21}

    subject.parameter_string.should eq expected_parameter_string
  end

  it 'provides the signature base string' do
    expected_signature_base_string = %q{POST&https%3A%2F%2Fapi.twitter.com%2F1%2Fstatuses%2Fupdate.json&include_entities%3Dtrue%26oauth_consumer_key%3Dxvz1evFS4wEEPTGEFPHBog%26oauth_nonce%3DkYjzVBB8Y0ZFabxSWbWovY3uYSQ2pTgmZeNu2VS4cg%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1318622958%26oauth_token%3D370773112-GmHxMAgYyLbNEtIKZeRNFsMKPR9EyMZeS9weJAEb%26oauth_version%3D1.0%26status%3DHello%2520Ladies%2520%252B%2520Gentlemen%252C%2520a%2520signed%2520OAuth%2520request%2521}

    subject.base_string.should eq expected_signature_base_string
  end

  it 'provides a signing key' do
    expected_signing_key = 'kAcSOqF21Fu85e7zjz7ZN2U4ZRhfV3WpwPAoE3Z7kBw&LswwdoUaIvS8ltyTth4J50vUPVVHtR2YPi5kE'

    subject.signing_key.should eq expected_signing_key
  end

  it 'calculates the signature' do
    expected_signature = 'Fz/2gWGHnXm6+QRzVUtANvhr1wI='

    subject.to_s.should eq expected_signature
  end

  it 'builds the signature given all the info' do
    expected_signature = 'Fz/2gWGHnXm6+QRzVUtANvhr1wI='
    signature = described_class.for http_method, base_url, params, oauth_params, secrets
    signature.should eq expected_signature
  end
end
