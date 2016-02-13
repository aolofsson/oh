Chip Design Glossary
===============================

All entries backed up by neutral Wiki entries.

## DESIGN
* [ASIC](https://en.wikipedia.org/wiki/Application-specific_integrated_circuit): Application specific integrated circuit.
* [Moore's Law](https://en.wikipedia.org/wiki/Moore%27s_law): Observation by Gordon Moore that the number of transistors in an IC doubles approximately every two years.
* [Mask Work](https://en.wikipedia.org/wiki/Integrated_circuit_layout_design_protection): A special field of US intellectual proprely law dedicated to 2D and 3D integrated circuit topogrophis "layouts".
* [Chip](https://en.wikipedia.org/wiki/Integrated_circuit): A set of electronic circuits on one small plate ("chip") of semiconductor material, normally silicon.
* [Die](https://en.wikipedia.org/wiki/Die_%28integrated_circuit%29): Small block of semioncuctor material that can be cut ("diced") from a silicon wafer
* [IP](https://en.wikipedia.org/wiki/Semiconductor_intellectual_property_core): Semiconductor reusable design blocks containing author's Intellectual Property. Can be licensed under open source or commercial terms.
* [EDA](https://en.wikipedia.org/wiki/Electronic_design_automation): Electronic Design Automation tools used to enhance chip design productivity.
* [GDSII](https://en.wikipedia.org/wiki/GDSII): Binary format of design database sent to foundry
* [DRC](https://en.wikipedia.org/wiki/Design_rule_checking): Design Rule Constraints specifying manufacturing constraints 
* [DFM](https://en.wikipedia.org/wiki/Design_for_manufacturability): Extended DRC rules specifying how to make a high yielding design. 
* [LVS](https://en.wikipedia.org/wiki/Layout_Versus_Schematic): Layout Versus Schematic software checks that the layout is identical to the netlist.
* [P&R](https://en.wikipedia.org/wiki/Place_and_route): Automated Place and Route of a ricuit using an EDA tool
* [Layout](https://en.wikipedia.org/wiki/Integrated_circuit_layout): Representation of an integrated circuit in terms of planar geometric shapes which correspond to the patterns of metal, oxide, or semiconductor layers that make up the components of the integrated circuit.
* [Spice](https://en.wikipedia.org/wiki/SPICE): Open source analog electronic circuit simulator
* [SOC](https://en.wikipedia.org/wiki/System_on_a_chip): System On Chip
* [Verilog](https://en.wikipedia.org/wiki/Verilog): Hardware description language (HDL)
* [DFT](https://en.wikipedia.org/wiki/Design_for_testing): Design for Test
* [BIST](https://en.wikipedia.org/wiki/Built-in_self-test): Built in Self Test
* [FPGA](https://en.wikipedia.org/wiki/Field-programmable_gate_array): Field-programmable gate array (FPGA) is an integrated circuit designed to be configured by a customer or a designer after manufacturing.
* [Logical Effort](https://en.wikipedia.org/wiki/Logical_effort): Term coined by Ivan Sutherland and Bob Sproull as a straightforward technique used to normalize delays in a circuit.
* [Tape-out](https://en.wikipedia.org/wiki/Tape-out): Act of sending photomask aDRCtwork of chip to manufacturer.
* [ESD](https://en.wikipedia.org/wiki/Electrostatic_discharge): Electrostatic discharge (ESD) is the sudden flow of electricity between two electrically charged objects caused by contact, an electrical short, or dielectric breakdown.
* [DEF](https://en.wikipedia.org/wiki/Design_Exchange_Format): Design Exchange Format for layout
* [LEF](https://en.wikipedia.org/wiki/Library_Exchange_Format): Standard Cell Library Exchange Format layout
* [Synthesis](https://en.wikipedia.org/wiki/Logic_synthesis): Translation of high level design description (eg Verilog) to a netlist format (eg standard cell gate level)
* [Flip-flop](https://en.wikipedia.org/wiki/Flip-flop_(electronics)): A clocked circuit that has two stable states and can be used to store state information. Usually understood toe be trigged on an edge.
* [PDK](https://en.wikipedia.org/wiki/Process_design_kit):  Process design kits consist of a set of files that typically contain descriptions of the basic building blocks of the process.
* [Foundry](https://en.wikipedia.org/wiki/Semiconductor_fabrication_plant): Semiconductor company offering manufacturing services
* [VLSI](https://en.wikipedia.org/wiki/Very-large-scale_integration): Very large Interated Circuit (somewhat outdated term, everything is VLSI today)
* [CMOS](https://en.wikipedia.org/wiki/CMOS): Complimentary metal-oxide semiconductor
* [FEOL](https://en.wikipedia.org/wiki/Front_end_of_line): Front end of line processing. Includes all chop processing up to but not including metal interconnect layers.
* [BEOL](https://en.wikipedia.org/wiki/Back_end_of_line): Back end of line processing for connecting together devices using metal interconnects.
* [Cadence](https://en.wikipedia.org/wiki/Cadence_Design_Systems): EDA and IP company
* [Synopsys](https://en.wikipedia.org/wiki/Synopsys): EDA and IP company
* [Mentor Graphics](https://en.wikipedia.org/wiki/Mentor_Graphics): EDA and IP company
* [MPW](https://en.wikipedia.org/wiki/Multi-project_wafer_service): Multi-project wafer service that integrates multiple designs on one reticle. Also referred to as a shuttle.
* [Latchup](https://en.wikipedia.org/wiki/Latch-up):A type of short circuit that can occur in a chip due to inadvertent creation of a low-impedance path between the power supply rails of a MOSFET circuit, triggering a parasitic structure which disrupts proper functioning of the part.
* [Antenna effect](https://en.wikipedia.org/wiki/Antenna_effect): Plasma induced gate oxide damage that can occur during semiconductor processing.
* [Power gating](https://en.wikipedia.org/wiki/Power_gating): Technique used to reduce leakage/standby power by shutting of the supply to the circuit.
* [Clock gating](https://en.wikipedia.org/wiki/Clock_gating): Technique to save power in synchronous logic design. Dynamically shuts off unused portions of the clock tree.
* [Multi-threshold CMOS](https://en.wikipedia.org/wiki/Multi-threshold_CMOS): Variation of CMOS technology with multiple threshold voltages to offer designer more options for meeting power and performance targets.
* [Cross talk](https://en.wikipedia.org/wiki/Crosstalk): The coupling of nearby signals on a chip, usually through capacitive coupling.
* [Signoff](https://en.wikipedia.org/wiki/Signoff_%28electronic_design_automation%29): The final stamp of approval that the design is ready to be sent to foundry for manufacturing.
* [STA](https://en.wikipedia.org/wiki/Static_timing_analysis): Method of computing the expected timing of a digital circuit without requiring a simulation of the full circuit.
* [SEU](https://en.wikipedia.org/wiki/Single_event_upset): Change of state caused by one single ionizing particle (ions, electrons, photons...) striking a sensitive node in a micro-electronic device
* [Electromigration](https://en.wikipedia.org/wiki/Electromigration): Transport of material caused by the gradual movement of the ions in a conductor due to the momentum transfer between conducting electrons and diffusing metal atoms.
* [PVT Corners](https://en.wikipedia.org/wiki/Process_corners): Represenets the extremes of the process, voltage, and temperature that could likely occur in a given semiconductor process. Can include combinations of FEOL (NMOS/PMOS) and BEOL, temperature (eg -40-->125 deg), and voltage (eg nominal +/- 10%).
* [EMI](https://en.wikipedia.org/wiki/Electromagnetic_interference): Electromagneic interference

## MANUFACTURING
* [FinFet](https://en.wikipedia.org/wiki/Multigate_device): Nonplanar, double-gate transistor.
* [Optical proximity correction](https://en.wikipedia.org/wiki/Optical_proximity_correction):  Photolithography enhancement technique used to compensate for image errors due to diffraction or process effects in semiconductor manufacturing. 
* [Semiconductor Fabrication](https://en.wikipedia.org/wiki/Semiconductor_device_fabrication): Process used to create the integrated circuits that are present in everyday electrical and electronic devices.
* [Photolithography](https://en.wikipedia.org/wiki/Photolithography): Process used in microfabrication to pattern parts of a thin film or the bulk of a substrate.
* [Photomasks](https://en.wikipedia.org/wiki/Photomask): Opaque plates with holes or transparencies that allow light to shine through in a defined pattern.
* [Reticle](https://en.wikipedia.org/wiki/Photomask): A set of photomasks used by a stepper to step and print patterns onto a silicon wafer.
* [Stepper](https://en.wikipedia.org/wiki/Stepper): Machine that passes light through reticle onto the silicon wafer being processed.
* [Dicing](https://en.wikipedia.org/wiki/CMOS): Act of cutting up wafer into individual dies
* [Bumping](https://en.wikipedia.org/wiki/Flip_chip): Placing of bumps on wafer/dies in preparation for package assemly
* [Wafer](https://en.wikipedia.org/wiki/Wafer_(electronics)): Tin slice of semiconductor material used in electronics for the fabrication of integrated circuits and in photovoltaics for conventional, wafer-based solar cells.
* [Silicon]():
* [Silicon on insulator](https://en.wikipedia.org/wiki/Silicon_on_insulator):  Layered silicon–insulator–silicon substrate in place to reduce parasitic device capacitance, thereby improving performance.
* [Backgrinding](https://en.wikipedia.org/wiki/Wafer_backgrinding): Wafer thickness is reduced to allow for stacking and high density packaging. Also referred to as "wafer thinning".
* [MLS](https://en.wikipedia.org/wiki/Moisture_sensitivity_level): Packaging and handling precautions for some semiconductors. 

## PACKAGING
* [WSI](https://en.wikipedia.org/wiki/Wafer-scale_integration): Wafer scale integration
* [MCM](https://en.wikipedia.org/wiki/Multi-chip_module): Multi-chip Module
* [SIP](https://en.wikipedia.org/wiki/System_in_package): System In Package
* [POP](https://en.wikipedia.org/wiki/Package_on_package): Package on Package
* [Interposer](https://en.wikipedia.org/wiki/Interposer): Electrical interface used to spread a connection to a wider pitch. Can be based on silicon, ceramic, or organic material.
* [Wirebond](https://en.wikipedia.org/wiki/Wire_bonding): Method of bonding a silicon die to a package using wires
* [Flip-chip](https://en.wikipedia.org/wiki/Flip_chip): Method of bonding a silicon die to package using solder bumps
* [BGA](https://en.wikipedia.org/wiki/Ball_grid_array): Ball grid array (BGA) is a type of surface-mount packaging (a chip carrier) used for integrated circuits.
* [BGA substrate](https://en.wikipedia.org/wiki/Ball_grid_array): A miniaturized PCB that mates the silicon die to BGA pins. 
* [Leadframe](https://en.wikipedia.org/wiki/Lead_frame): Metal structure inside a chip package that carry signals from the die to the outside. The die is glued to the leadframe and bond wires attach to the die pads.

## TEST
* [ATE](https://en.wikipedia.org/wiki/Automatic_test_equipment): Automated Test Equipment
* [Burn-in](https://en.wikipedia.org/wiki/Burn-in): Process of screening parts for potential premature life time failures.
* [KGD](https://en.wikipedia.org/wiki/Wafer_testing): Known Good Die. Dies that have been completely tested at wafer probe.
* [DUT](https://en.wikipedia.org/wiki/Device_under_test): Device under test
* [DIB](https://en.wikipedia.org/wiki/DUT_board): Device Interface Board for interfacing DUT to ATE. Also called DUT board, probecard, loadboard, PIB. 

















