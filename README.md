##DIRECTORY STRUCTURE
* **elink**:   Top level elink block
* **axi**:     Master and slave interface for elink
* **common**:  Various reusable blocks
* **eclock**:  Drives all clocks for elink and epiphany
* **ecfg**:    Configuration register file for the elink
* **gpio**:    GPIO block
* **i2c**:     I2C wrapper
* **etx**:     The elink transmitter logic
* **erx**:     The elink receiver logic
* **memory**:  Memory wrappers
* **emmu**:    Memory management unit
* **embox**:   Mailbox with interrupts

##DIRECTORY CONTENT
Each block should be considered a reusabel entitity and include
hdl source code as well as a basic test environment.

