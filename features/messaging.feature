Story: Producing and Consuming

  As a RosettaQueue user
  I want to publish and consume point-to-point using various messaging protocols
  So that I can reliably integrate my systems with a message broker

  Background:
    Given consumer logs have been cleared

  Scenario Outline: Point-to-Point
    Given RosettaQueue is configured for '<Adapter>'
    And a destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    And a consumer is listening to queue '<Queue>'
    When a message is published to '<Queue>'
    Then the message should be consumed from '<Queue>'

    Examples:
    | Adapter       | Queue    |  QueueAddress  |
    | amqp_synch    | foo      |  queue.foo     |
    | amqp_evented  | bar      |  queue.bar     |
    | stomp         | baz      |  /queue/baz    |
#| beanstalk     | baz      |  baz           |

  Scenario Outline: Delete queue
    Given RosettaQueue is configured for '<Adapter>'
    And a destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    When a message is published to '<Queue>'
    And the queue '<Queue>' is deleted
    Then the queue '<Queue>' should no longer exist

    Examples:
    | Adapter   | Queue    |  QueueAddress  |
    | amqp_synch  | foo      |  queue.foo   |


  @unreliable
  Scenario Outline: Publish-Subscribe
    Given RosettaQueue is configured for '<Adapter>'
    And a destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    And multiple consumers are listening to queue '<Queue>'
    When a message is published to '<Queue>'
    Then multiple messages should be consumed from '<Queue>'

    Examples:
   | Adapter    | QueueAddress  | Queue |
   | amqp_synch   | fanout.baz    | baz   |
   | amqp_evented | queue.foo     | foo   |
   | stomp        | /topic/foo     | bar   |
