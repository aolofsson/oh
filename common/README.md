
| Name            | Done | Function                            |
|-----------------|------|-------------------------------------|
| oh_rsync        |  Y   | Reset synchronzation circuit        |
| oh_dsync        |  Y   | Data synchronizizer                 |
| oh_mux{N}       |  Y   | Various one-hot muxes               |
| oh_edgealign    |  Y   | Aligns slow pulse to fast clock     |
| oh_pulse2pulse  |  Y   | Converts fast pulse to slow pulse   |
| oh_stretcher    |  Y   | Stetches a pulse                    |
| oh_clockdiv     |  N   | Clock divider                       |
| oh_arbiter      |  N   | Configurable arbiter                |
| oh_fifo_sync    |  Y   | FIFO with same rd/wr clocks         |
| oh_fifo_async   |  Y   | FIFO with seaprate rd/wr clocks     |
| oh_fifo_cdc     |  Y   | Clock domain crossing FIFO          |
| oh_memory_sp    |  Y   | Single ported memory                |
| oh_memory_dp    |  Y   | Dual ported memory                  |
| oh_standby      |  Y   | Low power standby circuit           |
| oh_clockgate    |  Y   | Low power clock gating circuit      |
| oh_datagate     |  Y   | Low power data gating circuit       |
| oh_lat0         |  Y   | Latch (active low)                  |
| oh_lat1         |  Y   | Latch (active high)                 |
| oh_add          |  Y   | Binary adder                        |
| oh_csa32        |  Y   | Full adder                          |
| oh_csa42        |  Y   | CSA4:2 Compressor                   |
| oh_abs          |  N   | Absolute value circuit              |
| oh_shifter      |  N   | Bonary shifter                      |
| oh_bin2gray     |  N   | Binary to gray converter            |
| oh_gray2bin     |  N   | Gray to binary converter            |
| oh_counter      |  N   | Multi-type counter                  |
| oh_crc          |  N   | CRC generator                       |
| oh_par2ser      |  N   | Parallel to serial converter        |
| oh_ser2par      |  N   | Serial to parallel converter        |







