Story: Producing and Consuming

  As a RosettaQueue user
  I want to publish and consume point-to-point using various messaging protocols
  So that I can reliably integrate my systems with a message broker

  Background:
    Given consumer logs do not exist

  Scenario Outline: Point-to-Point
    Given RosettaQueue is configured for '<Adapter>'
    And a point-to-point destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    And a consumer is listening to queue '<Queue>'
    When a message is published to queue '<Queue>'
    Then the message should be consumed

    Examples:
    | Adapter		| Queue    |  QueueAddress	|
    | amqp_synch	| foo      |  queue.foo		|
#    | stomp		| bar      |  queue/bar  	|
#    | beanstalk	| baz      |  baz  		|

  Scenario Outline: Delete queue
    Given RosettaQueue is configured for '<Adapter>'
    And a point-to-point destination is set with queue '<Queue>' and queue address '<QueueAddress>'
    When a message is published to queue '<Queue>'
    And the queue '<Queue>' is deleted
    Then the queue '<Queue>' should no longer exist

    Examples:
    | Adapter	  | Queue    |  QueueAddress	|
    | amqp_synch  | foo      |  queue.foo 	|


#   Scenario Outline: Publish-Subscribe
#     Given RosettaQueue is configured for '<Adapter>'
#     And a '<PublishSubscribe>' destination is set with key '<Key>' and queue '<Queue>'
#     When a message is published to 'foobar'
#     Then multiple messages should be consumed from the topic

#     Examples:
#    | Adapter    | PublishSubscribe  | Queue    |  QueueAddress	|
#    | amqp_synch | fanout    	      | foo  	 |  queue.foo 		|
#    | stomp      | topic     	      | foo    	 |  queue/foo 		|
