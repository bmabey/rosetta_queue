Story: Point-to-Point Producing and Consuming

  As a RosettaQueue user
  I want to publish and consume point-to-point using various messaging protocols
  So that I can reliably integrate my systems with a message broker

    Scenario Outline: Point-to-Point
      Given RosettaQueue is configured for '<Adapter>'
      And a point-to-point destination is set
      When a message is published to queue 'foo'
      Then the message should be consumed

  Examples:
  | Adapter   |
  | amqp      |
  | stomp     |
  | beanstalk |


  # Scenario Outline: Publish-Subscribe
  # Given RosettaQueue is configured for '<Adapter>'
  # And a publish-subscribe destination is set
  # When a message is published to topic foobar
  # Then multiple messages should be consumed from the topic
  #
  # Examples:
  # | Adapter   |
  # | amqp    |
  # # | stomp   |
  # #
