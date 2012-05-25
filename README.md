# Nervion

**An opinionated and minimalistic Twitter Stream API client.**

## Motivation
In a late project we had the need to consume the stream provided by twitter.
Although there are a couple of gems available we had to suffer the pain of poor
documentation and error swallowing (which made us lose a couple of days).

Once we found the error and we dug in the code we didn't like what we found.



This twitter client is built with the idea of having only one client per Ruby
 process.

## Installation

Add this line to your application's Gemfile:

    gem 'nervion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nervion


## Usage

Nervion mimics the endpoints provided by the
[Twitter Stream API](https://dev.twitter.com/docs/streaming-apis).
Currently it supports the
[Public Streams](https://dev.twitter.com/docs/streaming-apis/streams/public).

Specifically the two calls that are that are available to the broad audience:

- [`follow`](https://dev.twitter.com/docs/api/1/post/statuses/filter)
- [`sample`](https://dev.twitter.com/docs/api/1/get/statuses/sample)

[Firehose](https://dev.twitter.com/docs/api/1/get/statuses/firehose)
is not supported yet since requires a special access level.

Checkout the docs of both endpoints to know what tweets you can query the
Streaming API for.

You can specify any of the parameters supported by the endpoints by passing them
as named parameters to any of the methods provided by Nervion:


    require 'nervion'

    Nervion.filter(delimited: 1953, track: 'ruby', stall_warnings: true) do |parsed_status|
      #do something with the parsed status
    end


If Twitter adds more more parameters in the future they will be supported
straight away since Nervion does no work on the parameters: they are just
passed in.


###Authentication

Since Twitter plans to remove support for basic auth eventually, **Nervion only
supports OAuth authentication**.

You can provide the tokens and secrets in a configuration flavour:

    Nervion.configure do |config|
      config.consumer_key = the_consumer_key
      config.consumer_secret = the_consumer_secret
      config.access_token = the_access_token
      config.access_token_secret = the_access_token_secret
    end


Or provide them in the call itself:

    Nervion.filter(
      follow: '123456789',
      consumer_key: the_consumer_key,
      consumer_secret: the_consumer_secret,
      access_token: the_access_token,
      access_token_secret: the access_token_secret
    ) do |parsed_status|
      # do something with the parsed status
    end

If both are provided the ones on the call will be used.


###Parsing

Nervion will parse the JSON returned by twitter for you.

It uses [Yajl](https://github.com/brianmario/yajl-ruby)
as JSON parser for its out of the box support for JSON streams.

**In the process of parsing Nervion symbolizes keys**. You will always have to
use symbols to fetch data from the hashes that come out the parsing.


###Callbacks

The callbacks will receive only one parameter: the hash with the symbolized keys
resultant of the JSON parsing.

You get to choose what to do with the hash:
[mash](https://github.com/intridea/hashie) it before working with it or even
wrap it in some object that specializes on querying the information that is
relevant to you.

To know what to expect you should browse the
[*Platform Objects Documentation*](https://dev.twitter.com/docs/platform-objects/tweets).



####Status Callback

You can setup a callback that **acts on all the received statuses** by simply
passing in a block to the API call you are making:

    Nervion.sample { |status| puts status[:text] }

Be aware that **the callback will be called with any type of timeline update**
(or even with warnings if the `stall_warnings` parameter is set to `true`. Keep
this in mind when querying the hash.

Nervion **will support callbacks on specific types of tweets** in its next
version.

####Error Callback

There is also a callback for errors:

    Nervion.on_error do |error|
      SDTERR.puts "something went really bad: #{error}"
    end.sample


###Conection Handling

###EventMachine Integration


## Contributing

  1. Fork it
  2. Create your feature branch (`git checkout -b my-new-feature`)
  3. Commit your changes (`git commit -am 'Added some feature'`)
  4. Push to the branch (`git push origin my-new-feature`)
  5. Create new Pull Request
