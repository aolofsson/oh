| Project Management                         | Answer                         |
|--------------------------------------------|--------------------------------|
| Was git used for source control?           |                                |
| Were all sources under version control?    |                                |
| Were tapeout reports saved in src tree?    |                                |
| Was tapeout db archived and tagged?        |                                |

| Specification                              | Answer                         |
|--------------------------------------------|--------------------------------|
| Is there a written specification?          |                                |
| Is the datasheet complete and accurate?    |                                |
| Is there a user guide?                     |                                |
| What is the chip max power target?         |                                |
| What is the chip standby power target?     |                                |
| What is the chip yield target?             |                                |
| What is the chip cost target?              |                                |
| What is the max die size?                  |                                |
| What is the maximum die size?              |                                |
| How many signal IOs?                       |                                |
| What is the highest frequency IO?          |                                |

| Design                                     | Answer                         |
|--------------------------------------------|--------------------------------|
| In Verilog 2005 used?                      |                                |
| Are all features implemented?              |                                |
| Are all issues closed?                     |                                |
| Has design been through peer review?       |                                |
| Has a linter been run?                     |                                |
| Is there zero use of 'casex'?              |                                |
| Were Latches used? (If so list)            |                                |
| Were negedge flops used? (If so list)      |                                |
| Do all blocks have a license header?       |                                |
| Are all interface signals described?       |                                |
| Was naming methodology followed?           |                                |
| Lower case for all signals?                |                                |
| Upper case for parameters/defines?         |                                |
| Max 80 character line lengths?             |                                |
| Case or and/or style muxes used?           |                                |
| Non-blocking used for all states?          |                                |
| Was instantiation by name used?            |                                |
| Does each file contain one module          |                                |
| Is HDL reuse maximized?                    |                                |
| Has design been through peer review?       |                                |
| Are all signals connected?                 |                                |
| Any floating inputs in design?             |                                |
| All power-gated signals isolated?          |                                |
| All voltage domain crossings levelshifted? |                                |
| Is Verilog 2005 used?                      |                                |

| Verification                               | Answer                         |
|--------------------------------------------|--------------------------------|
| 100% HDL Code Coverage?                    |                                |
| 100% Unit Test Covergage?                  |                                |
| Random verifiation used?                   |                                |
| >24hrs of random vectors?                  |                                |
| Randomized clock frequencies?              |                                |
| Were all open issues closed?               |                                |

| Were all features tested?                  |                                |
| Simulator support for all features?        |                                |
| Was design emulated in an FPGA?            |                                |
| Was design validated with application SW?  |                                |
| Was formal equivalence run between HDL/GL? |                                |
| Is the firmware written?                   |                                |
| Is there a demo?                           |                                |


| Timing                                     | Answer                         |
|--------------------------------------------|--------------------------------|
| All paths constrained?                     |                                |
| All clocks defined?                        |                                |
| Max transition defined?                    |                                |
| Hold margin added?                         |                                |
| False paths reviewed/proven?               |                                |
| Setup time met?                            |                                |
| Hold time met?                             |                                |
| All paths constrained?                     |                                |
| Was clock path pessimism removed?          |                                |
| Was vmin/vmax verified?                    |                                |
| Was Tmin/Tmax verified?                    |                                |
| Was FF/SS/TT verified?                     |                                |
| On chip variability accounted for?         |                                |
| What other corners/modes were verified?    |                                |
                                
| Clock                                      | Answer                         |
|--------------------------------------------|--------------------------------|
| Percentage regs clock gated?               |                                |
| Integrated clock gating cells used?        |                                |
| Setup/hold verified on clock gating cells? |                                |
| Clock tree insertion delay?                |                                |
| Clock tree local skew?                     |                                |
| Clock tree global skew?                    |                                |
| Clock tree manually reviewed?              |                                |
| Double pitch/shield on main branch?        |                                |
| List of all clock domain crossings?        |                                |
| Use of oh_fifo_cdc on all CDCs?            |                                |
| Were custom CDCs used? (if so list)        |                                |

| Reset                                      | Answer                         |
|--------------------------------------------|--------------------------------|
| Is reset active low used?                  |                                |
| Is reset of type async entry, sync exit?   |                                |
| Are all reset pins synchronized?           |                                |
| Was oh_rsync used for every clk domain     |                                |
| Is use of reset minimized?                 |                                |
| Total fanout of reset signal?              |                                |

| Power                                      | Answer                         |
|--------------------------------------------|--------------------------------|
| Is a power mesh used?                      |                                |
| What is the simulated IR drop?             |                                |
| Was dynamic IR drop analysis run?          |                                |
| Were package parasitics simulated?         |                                |
| Does chip follow IP/foundry guidelines?    |                                |
| Standby power goal validated in simulation?|                                |
| Peak power goal validated in simulation?   |                                |

| IO                                         | Answer                         |
|--------------------------------------------|--------------------------------|
| Were ESD guidelines followed?              |                                |
| Were IO layout guidelines followed?        |                                |
| Was the IO reviewed by package team?       |                                |
| Are there sufficient power/gnd bumps       |                                |
| Can assembly team meet pitch requirements? |                                |
| What packaging style will be used?         |                                |
| Wirebond pad/pitch (if any)?               |                                |
| Flip-chip pad/pitch(if any)?               |                                |

| IP                                         |                                |
|--------------------------------------------|--------------------------------|
| Is all external IP silicon proven?         |                                |
| Are IP characterization reports available? |                                |
| Is the latest version IP being used?       |                                |
| Was the IP verilog model used for DV?      |                                |
| Wast the IP simulated in full-chip env?    |                                |
| Did you read all the documents?            |                                |
| Are there any open document questions?     |                                |
| Are all IP design checklists met?          |                                |

| Synthesis                                  | Answer                         |
|--------------------------------------------|--------------------------------|
| Was the correct/latest version of HDL used?|                                |
| Are all EDA warnings/errors acceptable?    |                                |
| The number of warnings has bee minimized?  |                                |

| Layout                                     | Answer                         |
|--------------------------------------------|--------------------------------|
| Synthesis/PNR                              | Answer                         |
|--------------------------------------------|--------------------------------|
| Is the flow completely automated?          |                                |
| Was the correct/latest version of HDL used?|                                |
| Are all EDA warnings/errors acceptable?    |                                |
| The number of warnings has bee minimized?  |                                |
| Was the correct/latest gate level used?    |                                |
| Are all EDA warnings/errors understood?    |                                |
| Are ECO/spare cells used?                  |                                |
| Were boundary cells included?              |                                |
| Were decoupling caps used?                 |                                |
| How many placed instances?                 |                                |
| What is the logic utilization?             |                                |
| Is block DRC clean?                        |                                |
| List any DRC violations?                   |                                |
| Is block LVS clean?                        |                                |
| List any LVS violations?                   |                                |
| Were the final foundry masks reviewed?     |                                |
| Were the minimal number of metals used?    |                                |
| Is the chip ring included                  |                                |
| Is the chip logo included                  |                                |
| Have gds layer map been manually reviewed? |                                |
| Has tapeout GDS been manually reviewed?    |                                |
| XOR check between foundry/design GDSIIs    |                                |

| DFM                                        | Answer                         |
|--------------------------------------------|--------------------------------|
| Were all foundry DFM guidlines followed?   |                                |
| Is column repair included in SRAM?         |                                |
| What is the percentage of double vias?     |                                |
| Is yield optimizing wire spreading used?   |                                |
| Does design include fault tolerance?       |                                |
| Does design meet metal density rules?      |                                |

| Test                                       | Answer                         |
|--------------------------------------------|--------------------------------|
| Does design use standard scan DFT?         |                                |
| What is the scan coverage?                 |                                |
| What is the PPM defect ratio target?       |                                |
| Are ATPG vectors generated?                |                                |
| What fault models are used for vectors?    |                                |
| What are the end user quality requirements?|                                |
| Are test ports controllable from pins?     |                                |
| What is the estimated test time?           |                                |
| Can all IO pins be tested for opens/short? |                                |
| Does chip include temp sensor?             |                                |

| Circuit Checks                             | Answer                         |
|--------------------------------------------|--------------------------------|
| Does design pass Signal Integrity checks?  |                                |
| Does gate level design boot out of reset?  |                                |
| Does design meeet Electromigration rules?  |                                |
| Does design meet antenna rules?            |                                |
| Are metastability requirement met?         |                                |
| Are soft error rate requirements met?      |                                |
| Are on-chip decoupling caps sufficient?    |                                |
| Are on-package decoupling caps sufficient? |                                |
| Are RC delays minimized?                   |                                |
| Are all latchup requirements met?          |                                |
| Design's lowest operating voltage?         |                                |
| What is the longest signal on the chip?    |                                |
| Is design sensitive to duty cycle shift?   |                                |
| What is the max duty-cycle distortion?     |                                |
| Does design meet EMI constraints?          |                                |
| ERC runset checks run on GDSII?            |                                |






