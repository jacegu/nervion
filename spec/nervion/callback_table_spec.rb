require 'nervion/callback_table'

describe Nervion::CallbackTable do
  it 'can be setup with a callback' do
    callback = stub(:callback)
    subject[:name]= callback
    subject[:name].should be callback
  end
end
