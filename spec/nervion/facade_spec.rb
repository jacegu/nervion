require 'nervion/facade'

describe "Facade that exposes Nervion's API" do
  let(:callback_table)   { mock(:callback_table).as_null_object }
  let(:status_callback)  { lambda { :status_callback } }
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

    context 'sample endpoint' do
      it 'sets up the status callback' do
        callback_table.should_receive(:[]=).with(:status, status_callback)
        Nervion.sample(&status_callback)
      end

      it 'starts the streaming to the sample endpoint' do
        Nervion.stub(:get).with(Nervion::SAMPLE_ENDPOINT, params, config).
          and_return(request)
        client.should_receive(:stream).with(request, callback_table)
        Nervion.sample(params, &status_callback)
      end
    end

    context 'filter endpoint' do
      it 'sets up the status callback' do
        callback_table.should_receive(:[]=).with(:status, status_callback)
        Nervion.filter(params, &status_callback)
      end

      it 'starts the streaming to the filter endpoint' do
        Nervion.stub(:post).with(Nervion::FILTER_ENDPOINT, params, config).
          and_return(request)
        client.should_receive(:stream).with(request, callback_table)
        Nervion.filter(params, &status_callback)
      end
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
