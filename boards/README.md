LIST OF OPEN SOURCE PRINTED CIRCUIT BOARDS
======================================================

>> Open source means that the original source code and design files are provided under a copyleft or permissive open source license. 

1. [List of Single Board Computers (SBCs)](#single-board-computers)
2. [List of RF Boards](#rf-boards)
3. [List of Camera Boards](#camera-boards)
4. [List of Other Boards](#other-boards)
5. [How to Add a Board](#how-to-add-a-board) 

---------------------------------------------------------------------

# Single Board Computers

| Name                                      | Type   | Tool    | Author           | Description                            |
|-------------------------------------------|--------|---------| -----------------| ---------------------------------------|
| [Arduino Uno](./arduino-uno.md)           | SBC    | SBC     | Arduino          | Arduino                                |
| [Beaglebone Black](./beaglebone-black.md) | SBC    | Allegro | CircuitCo        | TI processor SBC                       |
| [Olinuxino](./olinuxino.md)               | SBC    | KiCad   | Olimex           | Industrial grade SBC                   |
| [Parallella](./parallella.md)             | SBC    | Allegro | Adapteva         | SBC with Zynq FPGA + Epiphany          |
| [Rascal Micro](./rascal-micro.md)         | SBC    | Altium  | Brandon Stafford | SBC that works with Arduino shields    |

# RF Boards

| Name                                   | Type   | Tool    | Author              | Description                                  |
|----------------------------------------|--------|---------| --------------------| ---------------------------------------------|
| [Hack RF](./hackrf.md)                 | RF     | KiCad   | Great Scott Gadgets | 1MHz-6GHz Half Duplex RF board               |
| [Parallella Lime](./parallella-lime.md)| RF     | KiCad   | Lime Micro        | Parallella 300MHz-3.8GHz Parallella SDR board  |

# Camera Boards
| Name                                  | Type   | Tool    | Author     | Description                                     |
|---------------------------------------|--------|---------| -----------| ------------------------------------------------|
| [KVision](./kvision.md)               | Camera | Altium  | Emil Fresk | Parallella Stero camera board                   |

# Other Boards
| Name                                    | Type   | Tool    | Author     | Description                                     |
|-----------------------------------------|--------|---------|------------|-------------------------------------------------|
| [AAFM   ](./aafm.md)                    | FMC    | Allegro | BittWare   | FMC board with 4 Epiphany-III chips             |
| [OpenLog](./openlog.md)                 | Adapter| Eagle   | SparkFun   | Data logger                                     |
| [MicroSD Adapter](./microsd-adapter.md) | Adapter| Eagle   | Adafruit   | MicroSD to SD card adapter for RPI              |
| [Porcupine](./porcupine.md)             | Adapter| KiCad   | Adapteva   | Parallella breakout board                       |

# How to Add a Board
1. Fork this repository to your personal github account using the 'fork' button above
2. Clone your "OH" fork to a local computer using 'git clone'
3. Create a file "your_board".md in the "boards" directory
4. Update the table in this README.md file with a link to that new description
5. Use git add-->git commit-->git push to add changes to your fork of 'parallella-examples'
6. Submit a pull request by clicking the 'pull request' button on YOUR github 'OH' repo


