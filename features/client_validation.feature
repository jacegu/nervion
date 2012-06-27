Feature: Client setup validation

  Scenario: Missing authentication
    Given I haven't configured Nervion
     When I try to start streaming
     Then I get an error pointing me to the readme file
