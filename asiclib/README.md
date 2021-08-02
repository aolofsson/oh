ASICLIB
=====================================

* ASICLIB is a library of low level asic cells hard-coded to a specific PDK.
* The hdl/*.v files represent the golden model for the library. A hard coded implementation must implement the logical functionality exactly.
* The library is meant to be linked in at compile time based on the foundry being targeted.
* The cells do not have any dependancies.
