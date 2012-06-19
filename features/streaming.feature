Feature: Callbacks

  Background:
    Given the Twitter Streaming API is up
      And Nervion is connected to it

  Scenario: Calling the status callback
     When a status update is sent by Twitter
     Then Nervion calls the status callback with it

  Scenario: Calling the http error callback
     When an HTTP error occurs
     Then Nervion calls the HTTP error callback

  Scenario: Recovering from a network error
     When a network error occurs
     Then Nervion calls the network error callback
