# SPDX-FileCopyrightText: 2017 Scott Shawcroft, written for Adafruit Industries
# SPDX-FileCopyrightText: Copyright (c) 2023 Seth Kerr for Oak Development Technologies
#
# SPDX-License-Identifier: Unlicense

"""
Program the iCE40 FPGA and write IO expander registers with CircuitPython's
bit-banged SPI implementation.
"""

import gc
import time

import board
import bitbangio
import busio
import oakdevtech_icepython
from digitalio import DigitalInOut, Direction


WRITE_COMMAND = 0xF0

BLUE_CFG = 0x00
BLUE_OUT = 0x01
GREEN_CFG = 0x02
GREEN_OUT = 0x03
RED_CFG = 0x04
RED_OUT = 0x05
P13_CFG = 0x06
P13_OUT = 0x07
P20_CFG = 0x08
P20_OUT = 0x09

OUTPUT_ENABLE = 0x01
BIDIR_OUTPUT_ENABLE = 0x02


print("Mem Free: ", gc.mem_free(), "Mem Alloc", gc.mem_alloc())

spi = busio.SPI(clock=board.F_SCK, MOSI=board.F_MOSI, MISO=board.F_MISO)
iceprog = oakdevtech_icepython.Oakdevtech_icepython(
    spi, board.F_CSN, board.F_RST, "top.bin"
)

timestamp = time.monotonic()
iceprog.program_fpga()
endstamp = time.monotonic()

print("done in: ", (endstamp - timestamp), "seconds")


spi2 = bitbangio.SPI(clock=board.F2, MOSI=board.F4)
serial_enable = DigitalInOut(board.F3)
serial_enable.direction = Direction.OUTPUT
serial_enable.value = False


def write_register(address, value):
    serial_enable.value = True
    spi2.write(bytearray((WRITE_COMMAND, address & 0x0F, value & 0xFF)))
    serial_enable.value = False
    time.sleep(0.001)


while not spi2.try_lock():
    pass

spi2.configure(baudrate=100000, polarity=0, phase=0, bits=8)

write_register(BLUE_CFG, OUTPUT_ENABLE)
write_register(GREEN_CFG, OUTPUT_ENABLE)
write_register(RED_CFG, OUTPUT_ENABLE)
write_register(P13_CFG, BIDIR_OUTPUT_ENABLE | OUTPUT_ENABLE)
write_register(P20_CFG, BIDIR_OUTPUT_ENABLE | OUTPUT_ENABLE)

state = 0

while True:
    write_register(BLUE_OUT, state)
    write_register(GREEN_OUT, state ^ 0x01)
    write_register(RED_OUT, state)
    write_register(P13_OUT, state)
    write_register(P20_OUT, state ^ 0x01)

    state ^= 0x01
    time.sleep(0.5)
