require 'nervion/callback_table'

describe Nervion::CallbackTable do
  it 'can be setup with a callback' do
    callback = stub(:callback)
    subject[:name]= callback
    subject[:name].should be callback
  end

  it 'has a callback for network errors by default' do
    subject[:network_error].should_not be_nil
  end

  it 'has a callback for http errors by default' do
    STDERR.should_receive(:puts).with(/500|error/)
    subject[:http_error].call(500, 'error')
  end
end
