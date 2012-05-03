require 'nervion/request'

describe Nervion::Request do
  subject { described_class.new(http_method, uri) }

  let(:http_method) { :get }
  let(:uri) { 'https://stream.twitter.com/1/statuses/sample.json' }

  it 'is created with an http method' do
    subject.http_method.should eq http_method
  end

  it 'is created with an endpoint' do
    subject.uri.should be uri
  end

  context 'params' do
    it 'is created with no params by default' do
      subject.params.should eq Hash.new
    end

    it 'can be created with specific params' do
      params = { follow: '1,2,3' }
      request = described_class.new http_method, uri, params
      request.params.should eq params
    end
  end

  it 'builds the oauth authorization header' do
    oauth_header = 'OAuth param="param value"'
    Nervion::OAuthHeader.should_receive(:for).with(subject).
      and_return oauth_header
    subject.headers.should eq Hash[authorization: oauth_header]
  end

  context 'streaming' do
    let(:headers)    { Hash[authorization: 'OAuth header'] }
    let(:em_request) { stub :em_request }

    before do
      subject.stub(:headers).and_return headers
      EventMachine::HttpRequest.stub(:new).with(uri).and_return em_request
    end

    it 'triggers GET requests' do
      em_request.should_receive(:get).with(head: headers, query: {})
      subject.start
    end

    it 'triggers POST requests' do
      params = { follow: '1,2,3' }
      request = described_class.new('post', uri, params)
      request.stub(:headers).and_return headers
      em_request.should_receive(:post).with(head: headers, query: params)
      request.start
    end
  end

end
