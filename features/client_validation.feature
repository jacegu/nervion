Feature: Client setup validation

  Scenario: Missing authentication
    Given I haven't configured Nervion
     When I try to start streaming
     Then I get an error pointing me to the readme file

  Scenario Outline: Calling filter without a message callback
    Given Nervion has been configured
     When I try to start streaming the <endpoint_name> endpoint
     Then I get an error pointing me to the readme file

    Examples:
      | endpoint_name |
      | filter        |
      | firehose      |
      | sample        |
