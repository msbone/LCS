<h1>LCS 3.</h1>
This is only a proof of concept and not necessary how the LCS 3 will end up. <br>
The code is kinda bad and need rework and cleaning. The mix between PHP and Perl is also something to consider to change. 

<h3>The idea</h3>
Events should come in via the MQ (RabbitMQ). All database request should come via the API. <br>
The idea is that LCS can be used for more then the simple setup it is right now, and easy to extend without having to rewrite everything.
