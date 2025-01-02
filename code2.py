# SPDX-FileCopyrightText: 2017 Scott Shawcroft, written for Adafruit Industries
# SPDX-FileCopyrightText: Copyright (c) 2023 Seth Kerr for Oak Development Technologies
#
# SPDX-License-Identifier: Unlicense

"""
Example showing how to program an iCE40 FPGA with circuitpython!
"""

import time
import board, busio, bitbangio
import oakdevtech_icepython
import gc, random
from digitalio import DigitalInOut, Direction
print("Mem Free: ",gc.mem_free(),"Mem Alloc", gc.mem_alloc())
spi = busio.SPI(clock=board.F_SCK, MOSI=board.F_MOSI, MISO=board.F_MISO)

iceprog = oakdevtech_icepython.Oakdevtech_icepython(
    spi, board.F_CSN, board.F_RST, "top.bin"
)

timestamp = time.monotonic()

iceprog.program_fpga()

endstamp = time.monotonic()
print("done in: ", (endstamp - timestamp), "seconds")

flow = [[0,0,0,0,0,0,0,0, 1,0,0,0,1,0,0,1], # register first, LED output second
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1],
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1],
        [0,0,0,0,0,0,1,0, 0,1,0,0,0,0,0,1],
        [0,0,0,0,0,0,1,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,1, 0,0,0,0,0,0,0,1],
        [0,0,0,0,0,1,0,0, 0,1,1,1,1,1,1,1],
        [0,0,0,0,0,1,0,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,1,0,1, 0,0,0,0,0,0,0,1]]

# clock corresponds to pin 2 on the FPGA and MOSI corresponds to pin 4 on the FPGA.
spi2 = bitbangio.SPI(clock=board.F2, MOSI=board.F4)

# our chip select/enable pin
pico17 = DigitalInOut(board.F3)
pico17.direction = Direction.OUTPUT

while True:
    if spi2.try_lock():
        pico17.value = True # Enable pin for enabling data serial data storage
        time.sleep(0.01)
        # write to register 00h the value 91h
        # This enables the blue LED of the RGB LED in
        # PWM mode, with a pwm value of 001000 with the enable bit set to 1
        byte_flow = bytearray([0x00,0x91]) 
        spi2.write(byte_flow)
        pico17.value = False
        time.sleep(0.01)
        # if not in PWM mode, these two writes would toggle the
        # blue LED on and off every 100msec
        pico17.value = True
        byte_flow = bytearray([0x01,0x00])
        spi2.write(byte_flow)
        pico17.value = False
        time.sleep(0.1)
        pico17.value = True
        byte_flow = bytearray([0x01,0x01])
        spi2.write(byte_flow)
        pico17.value = False
        spi2.unlock()
        



