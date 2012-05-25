require 'nervion/request'

=begin
Content-Type: application/x-www-form-urlencoded
User-Agent: Nervion Twitter Streaming API Client
Accept-Encoding: deflate, gzip
Keep-Alive: true
=end


EXPECTED_REQUEST = <<REQUEST
GET /endpoint HTTP/1.1
Authorization: OAuth xxx
REQUEST

describe Nervion::Request do
  subject { described_class.new http_method, uri, params, oauth_params }

  let(:http_method)  { :get }
  let(:uri)          { 'https://twitter.com/endpoint' }
  let(:params)       { Hash.new }
  let(:oauth_params) { Hash[param: 'value'] }

  it 'is created with an http method' do
    subject.http_method.should eq :get
  end

  it 'is created with an uri' do
    subject.uri.should eq 'https://twitter.com/endpoint'
  end

  it 'is created with http params' do
    subject.params.should be params
  end

  it 'is created with oauth params' do
    subject.oauth_params.should eq Hash[param: 'value']
  end

  it 'knows the path it points to' do
    subject.path.should eq '/endpoint'
  end

  it 'composes the request' do
    Nervion::OAuthHeader.stub(:for).with(subject).and_return 'OAuth xxx'
    subject.request.should eq EXPECTED_REQUEST
  end
end
