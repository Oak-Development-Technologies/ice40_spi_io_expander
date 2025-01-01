# ice40_spi_io_expander
An IO Expander for ICE40 FPGA that interfaces over a SPI like interface.

# RPGA Feather Register Writes over SPI like interface Example

This is a novel example of sending values over a SPI like interface from the RP2040 to registers on tthe iCE5LP4K on the RPGA Feather. The associated `code.py` file contains an example of sending values to registers on the FPGA that correspond to the RGB LED enablement and output.

### How to build

To build, make sure the Yosys OSS CAD Suite tools are installed.

Download the most recent release from GitHub, source ${BASE_DIR}/oss-cad-suite/environment on Mac/Linux or install directly on Windows 10/11.

Once OSS CAD Suite is available, type the following into your command line terminal.

`make build` - this builds the binary file (bitstream) for the FPGA

`make prog` - this will program the SRAM on the FPGA directly, use this if you don't have on board flash. You'll need to reflash this bitstream any time you reset the FPGA or lose power.

`make prog_flash` - this will program the SPI Flash on the IcyBlue FPGA, or the SPI Flash on other boards that use the FT232H to program the on board FLASH.

### Coming Soon

`make load_cirpy` - This will check for a circuitpython drive mounted (will start Mac only), copy over the bin file to the circuitpython drive as well as a code.py containing the code to program a standalone fpga.

It will also clone down the Oakdevtech_Icepython library and copy it to the lib folder of the circuitpython drive.

### issues?

If you experience any issues, file an issue. :)