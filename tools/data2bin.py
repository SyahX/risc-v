#!/usr/bin/env python
# -*- encoding=utf-8 -*-

import argparse
import math
import os
import platform
import re
import select
import signal
import socket
import struct
import sys

# convert 32-bit int to byte string of length 4, from LSB to MSB
def int_to_byte_string(val):
	return struct.pack('<I', val)

def byte_string_to_int(val):
	return struct.unpack('<I', val)[0]

filename = sys.argv[1]
output = ""
for line in open(filename):
	output += int_to_byte_string(int(line, 16))
sys.stdout.write(output)
	

