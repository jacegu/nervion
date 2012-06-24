require 'nervion/request'

EXPECTED_GET_REQUEST = <<GET
GET /endpoint?p1=param%20value&p2=%24%26 HTTP/1.1\r
Host: twitter.com\r
Authorization: OAuth xxx\r\n\r
GET

EXPECTED_POST_REQUEST = <<POST
POST /endpoint HTTP/1.1\r
Host: twitter.com\r
Authorization: OAuth xxx\r
Content-Type: application/x-www-form-urlencoded\r
Content-Length: 26\r
\r
p1=param%20value&p2=%24%26\r
POST

describe Nervion::Request do
  let(:uri)          { 'https://twitter.com:443/endpoint' }
  let(:params)       { Hash[p1: 'param value', p2: '$&'] }
  let(:oauth_params) { Hash[param: 'value'] }

  shared_examples_for 'a request' do
    it 'is created with an uri' do
      subject.uri.should eq 'https://twitter.com/endpoint'
    end

    it 'is created with http params' do
      subject.params.should be params
    end

    it 'is created with oauth params' do
      subject.oauth_params.should eq Hash[param: 'value']
    end

    it 'knows the host it points to' do
      subject.host.should eq 'twitter.com'
    end

    it 'knows the port it will connect to' do
      subject.port.should eq 443
    end
  end

  context 'GET' do
    subject { Nervion.get(uri, params, oauth_params) }

    it 'has GET as http method' do
      subject.http_method.should eq 'GET'
    end

    it 'knows the path it points to with no params' do
      get_with_no_params = Nervion.get(uri, {}, oauth_params)
      get_with_no_params.path.should eq '/endpoint'
    end

    it 'knows the path it points to with params' do
      subject.path.should eq '/endpoint?p1=param%20value&p2=%24%26'
    end

    it 'has an string representation' do
      Nervion::OAuthHeader.stub(:for).with(subject).and_return 'OAuth xxx'
      subject.to_s.should eq EXPECTED_GET_REQUEST
    end

    it_behaves_like 'a request'
  end

  context 'POST' do
    subject { Nervion.post(uri, params, oauth_params) }

    it 'has POST as http method' do
      subject.http_method.should eq 'POST'
    end

    it 'knows the path it points to' do
      subject.path.should eq '/endpoint'
    end

    it 'has an string representation' do
      post = Nervion.post(uri, params, oauth_params)
      Nervion::OAuthHeader.stub(:for).with(post).and_return 'OAuth xxx'
      post.to_s.should eq EXPECTED_POST_REQUEST
    end

    it_behaves_like 'a request'
  end
end
