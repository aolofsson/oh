ASICLIB
=====================================

* ASICLIB is a library of low level "standard" cells hard-coded to a specific PDK.
* The hdl/*.v files represent the golden model for the library. Any hard coded library must implement the logical functionality exactly.
* The library is meant to be linked in at compile time based on the foundry being targeted.
* The cells do not have any dependancies.
