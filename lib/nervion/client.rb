require 'yajl'
require_relative 'request'

module Nervion
  class Client

    FILTER   = 'https://stream.twitter.com/1/statuses/filter.json'
    FIREHOSE = 'https://stream.twitter.com/1/statuses/firehose.json'
    SAMPLE   = 'https://stream.twitter.com/1/statuses/sample.json'

    def self.filter(parameters = {}, &callback)
      start_em_loop_with Request.new(:post, FILTER, parameters), callback
    end

    def self.firehose(parameters = {}, &callback)
      start_em_loop_with Request.new(:post, FIREHOSE, parameters), callback
    end

    def self.sample(parameters = {}, &callback)
      start_em_loop_with Request.new(:post, SAMPLE, parameters), callback
    end

    private

    def self.start_em_loop_with(request, callback)
      EM.run do
        request.start.stream do |data|
          parser.on_parse_complete = ->(parsed_object) { callback.call parsed_object }
          parser << data
        end
      end
    end

    def self.parser
      @parser ||= Yajl::Parser.new(symbolize_keys: true)
    end

  end
end
