Ethercat Design Notes
---------------------

Ethercat requires a short latency between incoming packet and outgoing
packet. The key to meeting this latency is to use a different design method
then usual for input and output.

Traditionally one would use 32 bit buffered ports to transport data. A port
with this level of buffering creates a 31-bit latency between a bit
arriving and a bit being processed; or 310 ns. Switching to 8 bit ports
creates a 70ns latency.

A second design criterion is that ports that are switched off should be
bypassed. In our design we are going to achieve this by rerouting channel
ends. THe end of a channel will always point to the first active transmit
port. This method will enable us to add no latency when skipping ports that
are not in use.
