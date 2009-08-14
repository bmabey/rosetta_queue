Story: Producing and Consuming

  As a RosettaQueue user
  I want to publish and consume point-to-point using various messaging protocols
  So that I can reliably integrate my systems with a message broker

  Scenario Outline: Point-to-Point
    Given RosettaQueue is configured for '<Adapter>'
    And a point-to-point destination is set
    When a message is published to queue 'foo'
    Then the message should be consumed
    
    Examples:
    | Adapter		|
    | amqp_synch	|
#    | stomp		| 
#    | beanstalk		| 

  Scenario Outline: Delete queue
    Given RosettaQueue is configured for '<Adapter>'
    And a point-to-point destination is set
    When a message is published to queue '<Queue>'
    And the queue '<Queue>' is deleted
    Then the queue '<Queue>' should no longer exist
    
    Examples:
    | Adapter		| Queue |
    | amqp_synch	| foo 	|


#   Scenario Outline: Publish-Subscribe
#     Given RosettaQueue is configured for '<Adapter>'
#     And a '<PublishSubscribe>' destination is set
#     When a message is published to 'foobar'
#     Then multiple messages should be consumed from the topic
    
#     Examples:
#    | Adapter		| PublishSubscribe	|
#    | amqp_synch	| fanout		|
#    | stomp		| topic			|
