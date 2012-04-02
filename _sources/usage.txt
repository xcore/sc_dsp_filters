Usage
-----

The app_ethercat_test application should be run on any number of XC-3 nodes
(to be replaced with Ethernet-slice when available) conencted to each
other.

* The left conncetor on the XC-3 is the main connector, the right
  connector can be used for chaining.

* The Ethernet connected to slice 0-0 is the main connector, the other four
  can be used for building a chain (or a tree!)

* An ethercat master needs to be inserted in the chain, connected to the
  first Ethercat slave. The master is in app_master_harness and is designed
  to run on an XC-2 (to be replaced by an slice too). The master sends an
  Ethercat packet every second, and prints it out no return, including the
  round-trip-time in 10 ns ticks.
