require 'eventmachine'
require 'yajl'
require_relative 'request'
require_relative 'configuration'

module Nervion
  FILTER  = 'https://stream.twitter.com/1/statuses/filter.json'
  SAMPLE  = 'https://stream.twitter.com/1/statuses/sample.json'

  def self.filter(parameters = {}, config = Configuration, &callback)
    Client.stream Request.new(:post, FILTER, parameters, config), &callback
  end

  def self.sample(parameters = {}, config = Configuration, &callback)
    Client.stream Request.new(:post, SAMPLE, parameters, config), &callback
  end


  def self.debu(parameters = {}, config = Configuration, &callback)
    Client.stream Request.new(:post, 'http://localhost:9000/', parameters, config), &callback
  end

  class Client
    def self.stream(request, &callback)
      new.stream request, &callback
    end

    def stream(request, &callback)
      EM.run do
        @parser = Yajl::Parser.new(symbolize_keys: true)
        request.start.stream { |data| process data, &callback }
      end
    end

    def process(data, &callback)
      begin
        @parser.on_parse_complete = ->(parsed_object) do
          CallbackDispatcher.for(&callback).succeed parsed_object
        end
        @parser << data
      rescue Yajl::ParseError
        EM.stop
        STDERR.puts "Twitter stream could not be parsed by Yajl (Maybe Twitter reported some error?):"
        STDERR.puts "<"*2
        STDERR.puts data.gsub(/^\s+$/, '').gsub(/\n\n+/, "\n")
        STDERR.puts ">"*2
      rescue Exception
        EM.stop
        raise
      end
    end

    class CallbackDispatcher
      include EM::Deferrable

      def self.for(&user_callback)
        new.callback { |parsed_object| user_callback.call(parsed_object) }
      end
    end

  end
end
