Feature: Callbacks

  Background:
    Given Nervion is connected to Twitter Streaming API

  Scenario: Calling the status callback
     When a status update is sent by Twitter
     Then Nervion calls the status callback with it

  Scenario: Calling the http error callback
     When an HTTP error occurs
     Then Nervion calls the HTTP error callback

  Scenario: Calling the network error callback
     When a network error occurs
     Then Nervion calls the network error callback
