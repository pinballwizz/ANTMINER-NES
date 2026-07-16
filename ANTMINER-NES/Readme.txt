NES Console for the ANTMINER S9 ZYNQ-7010 FPGA Board. Pinballwiz 2026
Code from Brian Bennett.

Notes:
Setup for keyboard controls in Upright mode (5 = Coin)(1 = Start P1)(2 = Start P2)(LCtrl = Jump)(Arrow Keys = Move Up or Down or Left or Right)
Consult the Docs Folder for Information regarding peripheral connections and schematics.

Build:
* Obtain NES roms and use included Nesdbg Utility to load to ANTMINER S9 Board via serial.
* Open the ANTMINER-NES project file using Vivado (v2022.2 or silimar is recommended)
* Compile the project updating filepaths to source files as necessary.
* If not using Zynq Arcade Platform connect JTAG Programmer and program ANTMINER S9 Board.
* If using Zynq Arcade (see the github repo) copy bitstream file to MicroSD Card and sys reset ANTMINER S9 Adapter board to load.
