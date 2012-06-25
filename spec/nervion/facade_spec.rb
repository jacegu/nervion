require 'nervion/facade'

describe "Facade that exposes Nervion's API" do
  let(:callback_table)   { mock(:callback_table).as_null_object }
  let(:message_callback)  { lambda { :message_callback } }
  let(:http_callback)    { lambda { :http_error_callback } }
  let(:network_callback) { lambda { :network_error_callback } }

  before { Nervion.stub(:callback_table).and_return(callback_table) }

  it 'provides a call to set up the http error callback' do
    callback_table.should_receive(:[]=).with(:http_error, http_callback)
    Nervion.on_http_error(&http_callback)
  end

  it 'provides a call to set up the network error callback' do
    callback_table.should_receive(:[]=).with(:network_error, network_callback)
    Nervion.on_network_error(&network_callback)
  end

  context 'chaining callback setup calls' do
    before do
      callback_table.should_receive(:[]=).with(:http_error, http_callback)
      callback_table.should_receive(:[]=).with(:network_error, network_callback)
    end

    it 'allows to chain callback setups' do
      Nervion.on_http_error(&http_callback).on_network_error(&network_callback)
    end

    it 'callback setups can be chained in any order' do
      Nervion.on_network_error(&network_callback).on_http_error(&http_callback)
    end
  end

  context 'streaming' do
    let(:client)  { stub(:client).as_null_object }
    let(:config)  { Nervion::Configuration }
    let(:params)  { Hash[stall_warnings: true] }
    let(:request) { stub :request }

    before do
      Nervion::Client.stub(:new).
        with(Nervion::STREAM_API_HOST, Nervion::STREAM_API_PORT).
        and_return(client)
    end

    shared_examples_for 'an endpoint' do
      it 'sets up the message callback' do
        callback_table.should_receive(:[]=).with(:message, message_callback)
        Nervion.send(method_name, params, &message_callback)
      end

      it 'starts the streaming to the sample endpoint' do
        Nervion.stub(http_method).with(endpoint, params, config).
          and_return(request)
        client.should_receive(:stream).with(request, callback_table)
        Nervion.send(method_name, params, &message_callback)
      end
    end

    context 'sample endpoint' do
      let(:http_method) { :get }
      let(:endpoint)    { Nervion::SAMPLE_ENDPOINT }
      let(:method_name) { :sample }

      it_behaves_like 'an endpoint'
    end

    context 'filter endpoint' do
      let(:http_method) { :post }
      let(:endpoint)    { Nervion::FILTER_ENDPOINT }
      let(:method_name) { :filter }

      it_behaves_like 'an endpoint'
    end

    context 'firehose endpoint' do
      let(:http_method) { :get }
      let(:endpoint)    { Nervion::FIREHOSE_ENDPOINT }
      let(:method_name) { :firehose }

      it_behaves_like 'an endpoint'
    end

    context 'stoping' do
      it 'can stop the streaming' do
        client.should_receive(:stop)
        Nervion.sample(->{})
        Nervion.stop
      end

      it 'raises an error if it is not streaming' do
        Nervion.instance_variable_set(:@client, nil)
        expect { Nervion.stop }.to raise_error
      end
    end
  end

end
