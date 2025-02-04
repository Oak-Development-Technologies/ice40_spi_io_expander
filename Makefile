SRC_DIR=src
PCF_DIR=common
filename=$(SRC_DIR)/top
pcf_file=$(PCF_DIR)/io.pcf

build:
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).v
	nextpnr-ice40 --u4k --package sg48 --json $(filename).json --pcf $(pcf_file) --pcf-allow-unconstrained --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	iceprog -S $(filename).bin

prog_flash:
	iceprog $(filename).bin

clean:
	rm -rf $(filename)*.blif $(filename)*.asc $(filename)*.bin $(filename)*.json