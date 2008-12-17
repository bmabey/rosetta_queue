Story: AMQP Producing and Consuming

  As a RosettaQueue user
  I want to publish and consume from a direct exchange using the AMQP protocol
  So that I can reliably integrate my systems with a message broker

  Scenario Outline: Direct Exchange
	Given RosettaQueue is configured for <Adapter>
	And a destination is set
	When a message is published to queue foo
    Then the message should be consumed
	
	Examples:
	| Adapter 	|
	| amqp		|
	| stomp		| 
	