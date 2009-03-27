Feature: Message Filtering
  In order to save time and prevent lots of typing
  As a RosettaQueue user
  I want to be able to define filters for processing all of my messages


  Scenario Outline: receiving filter
    Given RosettaQueue is configured for '<Adapter>'
    And a point-to-point destination is set
    And a receiving filter is defined to prepend 'Foo' to all messages
    And the message "Hello World" is published to queue "foo"
  
    When the message on "foo" is consumed
  
    Then the consumed message should equal "Foo Hello World"
    
    Examples:
    | Adapter     |
    | stomp       |
    | amqp        |   
    
  Scenario Outline: sending filter
    Given RosettaQueue is configured for '<Adapter>'
    And a point-to-point destination is set
    And a sending filter is defined to prepend 'Foo' to all messages
    And the message "Hello World" is published to queue "foo"

    When the message on "foo" is consumed

    Then the consumed message should equal "Foo Hello World"

    Examples:
    | Adapter     |
    | stomp       |
    | amqp        |
