# Nervion

**A minimalistic Twitter Stream API Ruby client**.


## Motivation

In our current project we had the need to consume the stream provided by twitter.
Although there are a few gems available we had to suffer the pain of poor
documentation and error swallowing, which made us lose a lot of time.

At that point I decided to build one on my own, and that's why you are reading
this.



## Installation

**WARNING: This project hasn't been released as a Gem yet**. This is here for
future reference.

Add this line to your application's Gemfile:

    gem 'nervion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nervion



## Overview

Nervion mimics the endpoints provided by the
[Twitter Stream API](https://dev.twitter.com/docs/streaming-apis).
Currently it supports the
[Public Streams](https://dev.twitter.com/docs/streaming-apis/streams/public).
In the future we will add support for the
[User Streams](https://dev.twitter.com/docs/streaming-apis/streams/user)
and the
[Site Streams](Use://dev.twitter.com/docs/streaming-apis/streams/site).

Specifically the two calls that are that are available to the broad audience:

- [`follow`](https://dev.twitter.com/docs/api/1/post/statuses/filter)
- [`sample`](https://dev.twitter.com/docs/api/1/get/statuses/sample)
- [`firehose`](https://dev.twitter.com/docs/api/1/get/statuses/firehose)
is not supported yet since requires a special access level.

Checkout the docs of both endpoints to know what tweets you can query the
Streaming API for.

You can specify any of the parameters supported by the endpoints by passing them
as named parameters to the provided methods:

```ruby
require 'nervion'

Nervion.filter(delimited: 1953, track: 'ruby', stall_warnings: true) do |parsed_status|
  #do something with the parsed status
end
```

If the API adds support for more parameters in the future they will be supported
straight away since Nervion does no work on them: they are just submitted to
Twitter.



### JSON Parsing

**Nervion will parse the JSON returned by twitter for you**. It uses
[Yajl](https://github.com/brianmario/yajl-ruby) as JSON parser for its out of
the box support for JSON streams.

**The hash keys are symbolized in the process of parsing**. You will always have
to use symbols to fetch data in the callbacks.


## Authentication

Since Twitter plans to remove support for basic auth eventually, **Nervion only
supports OAuth authentication**.

You can provide the tokens and secrets in a configuration flavour:

```ruby
Nervion.configure do |config|
  config.consumer_key = the_consumer_key
  config.consumer_secret = the_consumer_secret
  config.access_token = the_access_token
  config.access_token_secret = the_access_token_secret
end
```



## Callbacks

Nervion provides three callbacks:

- **Status callback**: This callback will be called with every item of the stream
- **HTTP error callback**: This callback is called when Twitter responds with a status above 200
- **Network error callback**: This callback will be called when the connection to the stream is lost


### Status Callback

You can setup a callback that **acts on all the received statuses** by simply
passing in a block to the API call you are making:

```ruby
Nervion.sample { |status| puts status[:text] if status.has_key? :text }
```

Be aware that **the callback will be called with any type of timeline update**
(or even with warnings if the `stall_warnings` parameter is set to `true`. Keep
this in mind when querying the hash.

The callbacks will receive only one parameter: the hash with the symbolized keys
resultant of the JSON parsing. You get to choose what to do with the hash:
[mash](https://github.com/intridea/hashie) it before working with it or even
wrap it in some object that specializes on querying the information that is
relevant to you.

To know what keys to expect you should browse the
[*Platform Objects Documentation*](https://dev.twitter.com/docs/platform-objects/tweets).


### HTTP Error Callback

This callback will be executed when the Streaming API sends a response with a
status code above 200. After the callback has been executed a retry will be
scheduled adhering to the
[connection Guidelines](https://dev.twitter.com/docs/streaming-api/concepts#connecting)
provided by twitter.

You can setup the callback like this:

```ruby
Nervion.on_http_error do |status, body|
  puts "Response status was: #{status}"
  puts "Response body was: #{body}"
end
```

If no callback is set, Nervion's default behaviour will be to output the an
error message to `STDERR` that contains both the status and the body of Twitter
Streaming API's response.


### Network Error callback

This callback will be executed when the connection with the Twitter Stream API
is unexpectedly closed.

```ruby
Nervion.on_network_error do
  puts 'There was a connection error but Nervion will automatically reconnect'
end
```

**Nervion will do nothing by default when network errors occurr** because it is
unlikely that they are provoked by the client itself.

### Callback chaining

Callback setup can be chained like this:

```ruby
Nervion.on_network_error do
  #do something about the error
end.on_http_error do |status, body|
  #do something about the error
end.sample do |status|
  #do something with the status
end
```

## EventMachine Integration

Nervion runs on the top of EventMachine.

In the near future this `README` will provide a guideline to take advantage of
the benefits that EventMachine can provide when used correctly.

## Roadmap

There are some features that are needed and that will be developed before the first
release of the gem:

  - <del>Provide an HTTP error callback</del> *done!*
  - <del>Provide a network error callback</del> *done!*
  - <del>Adhere to the
  [Twitter Connection guidelines](https://dev.twitter.com/docs/streaming-api/concepts#connecting)</del>
  *done!*
  - Improve the DSL provided to setup Nervion to validate the client setup

In the near future Nervion will use a gzip compressed stream