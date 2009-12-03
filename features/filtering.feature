Feature: Message Filtering
  In order to save time and prevent lots of typing
  As a RosettaQueue user
  I want to be able to define filters for processing all of my messages


  Scenario Outline: receiving filter
    Given RosettaQueue is configured for '<Adapter>'
    And a destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    And a receiving filter is defined to prepend 'Foo' to all messages
    And the message 'Hello World' is published to queue '<Queue>'
    When the message on '<Queue>' is consumed
    Then the consumed message should equal "Foo Hello World"

    Examples:
    | Adapter     | Queue    |  QueueAddress  |
    | amqp_synch  | foo      |  queue.foo     |
    | stomp       | foo      |  /queue/foo    |

  Scenario Outline: sending filter
    Given RosettaQueue is configured for '<Adapter>'
    And a destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    And a sending filter is defined to prepend 'Foo' to all messages
    And the message 'Hello World' is published to queue '<Queue>'
    When the message on '<Queue>' is consumed
    Then the consumed message should equal "Foo Hello World"

    Examples:
    | Adapter     | Queue    |  QueueAddress  |
    | amqp_synch  | foo      |  queue.foo     |
    | stomp       | foo      |  /queue/foo    |
