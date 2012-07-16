# Nervion [![Build Status](https://secure.travis-ci.org/jacegu/nervion.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/jacegu/nervion.png?travis)][gemnasium] [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/jacegu/nervion)

**A minimalistic Ruby client for the
[Public Streams](https://dev.twitter.com/docs/streaming-apis/streams/public)
of Twitter Streaming API**.

[travis]: http://travis-ci.org/jacegu/nervion
[gemnasium]: https://gemnasium.com/jacegu/nervion



## Installation

Add this line to your application's Gemfile:

    gem 'nervion'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nervion



## Overview

**Nervion's API has a static look**. Given that Twitter only allows one
connection per client to the Public Streams there is no need for you to
build and handle a `Nervion::Client`. Nervion does that for you.
You only need to set up the authentication and call the endpoint you are
interested in.

Nervion mimics the endpoints provided by the
[Twitter Stream API](https://dev.twitter.com/docs/streaming-apis)
through the following methods:

- [`follow`](https://dev.twitter.com/docs/api/1/post/statuses/filter)
- [`sample`](https://dev.twitter.com/docs/api/1/get/statuses/sample)
- [`firehose`](https://dev.twitter.com/docs/api/1/get/statuses/firehose)
*notice that the firehose support hasn't been tested against the actual API
since it requires a level of access I don't have. If you were able to verify
that it works, please, let me know*

Checkout the docs of the endpoints to know what tweets you can query the
Streaming API for and what parameters you have to provide to do so. You can
specify any of the parameters supported by the endpoints by passing them
as named parameters to the provided methods:

```ruby
# This is tracking every tweet that includes the string "madrid" OR any tweet
# that is geo-located in Madrid.
Nervion.filter(track: 'madrid', locations: '40.364,-3.760,40.365,-3.609') do |message|
  # do something with the message
end
```

If the API adds support for more parameters in the future they will be supported
straight away since Nervion does no work on them: they are just submitted to
Twitter.



## Authentication

Since Twitter plans to remove support for basic auth eventually, **Nervion only
supports OAuth authentication**.

You can provide the tokens and secrets in a configuration flavour:

```ruby
Nervion.configure do |config|
  config.consumer_key        = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  config.consumer_secret     = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  config.access_token        = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
  config.access_token_secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
end
```



## JSON Parsing

**Nervion will parse the JSON returned by twitter for you**. It uses
[Yajl](https://github.com/brianmario/yajl-ruby) as JSON parser for its out of
the box support for JSON streams.

**The hash keys are symbolized in the process of parsing**. You will always have
to use symbols to fetch data in the callbacks.



## Callbacks

Nervion provides three callbacks:

- **Message callback**: called when message is received and parsed
- **HTTP error callback**: called when Twitter responds with a status above 200
- **Network error callback**: called when the connection to the stream is lost


### Message Callback

You must setup a callback that **acts on all the received messages** by simply
passing in a block to the API call you are making:

```ruby
Nervion.sample { |message| puts message[:text] if message.has_key? :text }
```

Be aware that
**[every message type](https://dev.twitter.com/docs/streaming-apis/messages)
will trigger this callback**. Keep this in mind when querying the hash.

The callback receives only one parameter: the hash with the symbolized keys
resultant of the JSON parsing. You get to choose what to do with the hash:
[mash](https://github.com/intridea/hashie) it before working with it or even
wrap it in some object that specializes on querying the information that is
relevant to you.

To know what keys to expect you should browse the
[*Platform Objects Documentation*](https://dev.twitter.com/docs/platform-objects/tweets)
and know the different
[message types](https://dev.twitter.com/docs/streaming-apis/messages)
.


### HTTP Error Callback

This callback will be executed when the Streaming API sends a response with a
status code above 200. After the callback has been executed a retry will be
scheduled adhering to the
[connection Guidelines](https://dev.twitter.com/docs/streaming-api/concepts#connecting)
provided by twitter.

You can setup the callback like this:

```ruby
Nervion.on_http_error do |status, body|
  puts "the status of the response was: #{status}"
  puts "the body of the response body was: #{body}"
end
```

Given that most of the HTTP errors are due to client configuration, if no
callback is set, Nervion's default behaviour will be to output an error message
to `STDERR` that contains both the status and the body of Twitter Streaming
API's response.


### Network Error callback

This callback will be executed when the connection with the Twitter Stream API
is unexpectedly closed.

```ruby
Nervion.on_network_error do
  puts 'There was a connection error but Nervion will automatically reconnect'
end
```

Nervion will do nothing by default when network errors occur because it is
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

Nervion runs on the top of EventMachine. This means that you can take advantage
of any of the features of the EventMachine ecosystem in your Nervion callbacks.

Nervion can be run insinde an instance of EventMachine that is already running
or you can let Nervion handle the event loop for you.

With that purpose in mind Nervion provides a few handy methods:

### stop

The `stop` method will stop both the streaming and EventMachine.

```ruby
  Nervion.stop
```

### close_stream

You can use `close_stream` to close the connection to the streaming API but
keep EventMachine's event loop running.

```ruby
  Nervion.close_stream
```

### running?

The `running?` method will allow you to check whether Nervion is already
running or not, what, in the asyncronous land that EventMachine lives in, you
may not be sure about.

```ruby
  Nervion.running?
```

And remember **do not block the event loop**.



## Roadmap

There are some features that are needed and that will be developed before the first
release of the gem:

  - <del>Provide an HTTP error callback</del> *done!*
  - <del>Provide a network error callback</del> *done!*
  - <del>Adhere to the
  [Twitter Connection guidelines](https://dev.twitter.com/docs/streaming-api/concepts#connecting)</del>
  *done!*
  - <del>Improve the DSL provided to setup Nervion to validate the client
  setup</del> *done!*

Future features will be:

  - Use a gzip compressed stream
  - Be able to configure the client to skip parsing and yield bare Strings with
  the JSON of the streamed messages. The objective is to improve performance by
  parsing in other process.
