# SPDX-FileCopyrightText: 2017 Scott Shawcroft, written for Adafruit Industries
# SPDX-FileCopyrightText: Copyright (c) 2023 Seth Kerr for Oak Development Technologies
#
# SPDX-License-Identifier: Unlicense

"""
Example showing how to program an iCE40 FPGA with circuitpython and send some values over a SPI like
Interface.
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

print("done")

# setting up the registers to determine the output of the pins is important
# first we send the address which is the first 8 bits (first byte) of the message
# the second byte of the message has the anatomy for the following
# [0] - This byte is the PWM enable bit
# [1-6] - Bits 1-6 are the PWM value of the output if PWM is enabled
# [7] - is the output enable bit
#
# These bits are assigned for even address spaces starting from address 00h
# 
# Right now, for odd addresses starting at 01h, only the last bit sent is used to
# toggle the value of the output if PWM is not enabled.

flow = [[0,0,0,0,0,0,0,0, 1,0,0,0,1,0,0,1], # register first, LED output second
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1],
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,1, 0,0,0,0,0,0,0,1],
        [0,0,0,0,0,0,1,0, 0,1,1,1,1,1,1,1],
        [0,0,0,0,0,0,1,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,1, 0,0,0,0,0,0,0,1],
        [0,0,0,0,0,1,0,0, 0,1,1,1,1,1,1,1],
        [0,0,0,0,0,1,0,1, 0,0,0,0,0,0,0,0],
        [0,0,0,0,0,1,0,1, 0,0,0,0,0,0,0,1]]

pico16 = DigitalInOut(board.F2)
pico16.direction = Direction.OUTPUT
pico17 = DigitalInOut(board.F3)
pico17.direction = Direction.OUTPUT
pico18 = DigitalInOut(board.F4)
pico18.direction = Direction.OUTPUT
pico19 = DigitalInOut(board.F6)
pico19.direction = Direction.OUTPUT
pico20 = DigitalInOut(board.F48)
pico20.direction = Direction.INPUT

pico16.value = False # clock to provide edge for data input
pico17.value = True # Enable pin for enabling data serial data storage
pico18.value = False # serial data to FPGA
pico19.value = True

count = 0
flow_cnt = 0


while True:
    if (count == 16):
        count = 0
        flow_cnt = flow_cnt + 1
        if (flow_cnt == 11):
            flow_cnt = 0
        print("count reset", flow_cnt)
        #pico16.value = False
        pico17.value = False
        #time.sleep(0.05)
        #pico16.value = True
        #time.sleep(0.01)
        
    pico17.value = True
    if (pico16.value):
        pico16.value = False
    else:
        pico18.value = flow[flow_cnt][count]
        pico16.value = True
        print("doing some stuff, data: ", pico18.value)
        if (count < 16):
            count = count + 1

    time.sleep(0.01)
