require 'nervion/client'

describe Nervion do
  let(:params)   { stub :params }
  let(:request)  { stub :request }
  let(:callback) { lambda {} }

  it 'creates a sample stream client' do
    Nervion.stub(:get).
      with(Nervion::SAMPLE_ENDPOINT, params, Nervion::Configuration).
      and_return(request)
    Nervion::Client.should_receive(:stream).with(request, &callback)
    Nervion.sample(params, &callback)
  end

  it 'creates a sample stream client without params' do
    Nervion.stub(:get).
      with(Nervion::SAMPLE_ENDPOINT, {}, Nervion::Configuration).
      and_return(request)
    Nervion::Client.should_receive(:stream).with(request, &callback)
    Nervion.sample(&callback)
  end

  it 'creater a filter stream client' do
    Nervion.stub(:post).
      with(Nervion::FILTER_ENDPOINT, params, Nervion::Configuration).
      and_return(request)
    Nervion::Client.should_receive(:stream).with(request, &callback)
    Nervion.filter(params, &callback)
  end
end
