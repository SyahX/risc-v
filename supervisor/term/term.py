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
import string
import struct
import subprocess
import sys
import tempfile
from timeit import default_timer as timer
try:
    import serial
except:
    print("Please install pyserial")
    exit(1)
try:
    import readline
except:
    pass
try: type(raw_input)
except NameError: raw_input = input

CCPREFIX = "/PATH/bin/riscv32-unknown-elf-"
if 'GCCPREFIX' in os.environ:
    CCPREFIX=os.environ['GCCPREFIX']

Reg_alias = ['zero', 'ra', 'sp', 'gp', 'tp', 't0', 't1', 't2', 's0', 's1', 'a0', 'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 's2', 's3', 's4', 's5', 's6', 's7', 's8', 's9', 's10', 's11', 't3', 't4', 't5', 't6']

# convert 32-bit int to byte string of length 4, from LSB to MSB
def int_to_byte_string(val):
    return struct.pack('<I', val)

def byte_string_to_int(val):
    return struct.unpack('<I', val)[0]

# invoke assembler to encode single instruction (in little endian MIPS32)
# returns a byte string of encoded instruction, from lowest byte to highest byte
# returns empty string on failure (in which case assembler messages are printed to stdout)
# TODO:确定命令行的参数
def single_line_asm(instr):
    tmp_asm = tempfile.NamedTemporaryFile(delete=False)
    tmp_obj = tempfile.NamedTemporaryFile(delete=False)
    tmp_binary = tempfile.NamedTemporaryFile(delete=False)

    try:
        tmp_asm.write((instr + "\n").encode('utf-8'))
        tmp_asm.close()
        tmp_obj.close()
        tmp_binary.close()
        subprocess.check_output([
            CCPREFIX + 'as', '-march=rv32i', '-mabi=ilp32', tmp_asm.name, '-o', tmp_obj.name])
        subprocess.check_call([
            CCPREFIX + 'objcopy', '-j', '.text', '-O', 'binary', tmp_obj.name, tmp_binary.name])
        with open(tmp_binary.name, 'rb') as f:
            binary = f.read()
            if len(binary) > 4:
                binary = binary[:4]
            # assert len(binary) == 4, \
            #     "the result does not contains exactly one instruction, " + \
            #     "%d instruction found" % (len(binary) / 4)
            return binary
    except subprocess.CalledProcessError as e:
        print(e.output)
        return ''
    except AssertionError as e:
        print(e)
        return ''
    finally:
        os.remove(tmp_asm.name)
        # object file won't exist if assembler fails
        if os.path.exists(tmp_obj.name):
            os.remove(tmp_obj.name)
        os.remove(tmp_binary.name)

# invoke objdump to disassemble single instruction
# accepts encoded instruction (exactly 4 bytes), from least significant byte
# objdump does not seem to report errors so this function does not guarantee
# to produce meaningful result
def single_line_disassmble(binary_instr):
    assert(len(binary_instr) == 4)
    tmp_binary = tempfile.NamedTemporaryFile(delete=False)
    tmp_binary.write(binary_instr)
    tmp_binary.close()

    raw_output = subprocess.check_output([
        CCPREFIX + 'objdump', '-D', '-b', 'binary',
        '-m', 'riscv:rv32', tmp_binary.name])
    # the last line should be something like:
    #    0:   21107f00        addu    v0,v1,ra
    result = raw_output.strip().split(b'\n')[-1].split(None, 2)[-1]

    os.remove(tmp_binary.name)

    return result.decode('utf-8')

# A operation: input assembly code into specified address
def run_A(addr):
    print("one instruction per line, empty line to end.")
    while True:
        line = raw_input('[0x%04x] ' % addr)
        if line.strip() == '':
            return
        try:
            instr = int_to_byte_string(int(line, 16))
        except ValueError:
            instr = single_line_asm(line)
            if instr == '':
                continue
        outp.write(b'A')
        outp.write(int_to_byte_string(addr))
        outp.write(int_to_byte_string(4))
        outp.write(instr)
        addr = addr + 4

# R operation: To show content in all register
def run_R():
    outp.write(b'R')
    for i in range(1, 32):
        val_raw = inp.read(4)
        val = byte_string_to_int(val_raw)
        print('R{0}{1:7} = 0x{2:0>8x}'.format(
            str(i).ljust(2),
            '(' + Reg_alias[i] + ')',
            val,
        ))

# D operation: show content in specified address
def run_D(addr, num):
    if num % 4 != 0:
        print("num % 4 should be zero")
        return
    outp.write(b'D')
    outp.write(int_to_byte_string(addr))
    outp.write(int_to_byte_string(num))
    counter = 0
    while counter < num:
        val_raw = inp.read(4)
        counter = counter + 4
        val = byte_string_to_int(val_raw)
        print('0x%08x: 0x%08x' % (addr,val))
        addr = addr + 4

# U operation: read data in specified instruction address and deassembly to assemble language
def run_U(addr, num):
    if num % 4 != 0:
        print("num % 4 should be zero")
        return
    outp.write(b'D')
    outp.write(int_to_byte_string(addr))
    outp.write(int_to_byte_string(num))
    counter = 0
    while counter < num:
        val_raw = inp.read(4)
        print('0x%08x: %s' % (addr,single_line_disassmble(val_raw)))
        counter = counter + 4
        addr = addr + 4

# G operation: run code from specified address
def run_G(addr):
    outp.write(b'G')
    outp.write(int_to_byte_string(addr))
    class TrapError(Exception):
        pass
    try:
        ret = inp.read(1)
        if ret == b'\x80':
            raise TrapError()
        if ret != b'\x06':
            print("start mark should be 0x06")
        time_start = timer()
        while True:
            ret = inp.read(1)
            if ret == b'\x07':
                break
            elif ret == b'\x80':
                raise TrapError()
            if hasattr(sys.stdout, 'buffer'):
                sys.stdout.buffer.write(ret)
            else:
                text  = ret.decode(sys.stdout.encoding, 'strict')
                sys.stdout.write(text)
        print('') #just a new line
        elapse = timer() - time_start
        print('elapsed time: %.3fs' % (elapse))
    except TrapError:
        print('supervisor reported an exception during execution')

def MainLoop():
    while True:
        try:
            cmd = raw_input('>> ').strip().upper()
        except EOFError:
            break
        EmptyBuf()
        try:
            if cmd == 'Q':
                break
            elif cmd == 'A':
                addr = raw_input('>>addr: 0x')
                run_A(int(addr, 16))
            elif cmd == 'R':
                run_R()
            elif cmd == 'D':
                addr = raw_input('>>addr: 0x')
                num = raw_input('>>num: ')
                run_D(int(addr, 16), int(num))
            elif cmd == 'U':
                addr = raw_input('>>addr: 0x')
                num = raw_input('>>num: ')
                run_U(int(addr, 16), int(num))
            elif cmd == 'G':
                addr = raw_input('>>addr: 0x')
                run_G(int(addr, 16))
            elif cmd == 'T':
                num = raw_input('>>num: ')
                run_T(int(num))
            else:
                print("Invalid command")
        except ValueError as e:
            print(e)

def InitializeSerial(pipe_path, baudrate):
    global outp, inp
    tty = serial.Serial(port=pipe_path, baudrate=baudrate)
    tty.reset_input_buffer()
    inp = tty
    outp = tty
    return True

def Main(welcome_message=True):
    #debug
    # welcome_message = False
    if welcome_message:
        print(inp.read(33))
    MainLoop()

# QEMU uses this, but our team haven't use this, can not guarantee it's right
class tcp_wrapper:

    def __init__(self, sock=None):
        if sock is None:
            self.sock = socket.socket(
                socket.AF_INET, socket.SOCK_STREAM)
        else:
            self.sock = sock

    def connect(self, host, port):
        self.sock.connect((host, port))

    def write(self, msg):
        totalsent = 0
        MSGLEN = len(msg)
        while totalsent < MSGLEN:
            sent = self.sock.send(msg[totalsent:])
            if sent == 0:
                raise RuntimeError("socket connection broken")
            totalsent = totalsent + sent

    def flush(self): # dummy
        pass

    def read(self, MSGLEN):
        chunks = []
        bytes_recd = 0
        while bytes_recd < MSGLEN:
            chunk = self.sock.recv(min(MSGLEN - bytes_recd, 2048))
            # print 'read:...', list(map(lambda c: hex(ord(c)), chunk))
            if chunk == b'':
                raise RuntimeError("socket connection broken")
            chunks.append(chunk)
            bytes_recd = bytes_recd + len(chunk)
        return b''.join(chunks)

    def reset_input_buffer(self):
        local_input = [self.sock]
        while True:
            inputReady, o, e = select.select(local_input, [], [], 0.0)
            if len(inputReady) == 0:
                break
            for s in inputReady:
                s.recv(1)

def EmptyBuf():
    inp.reset_input_buffer()

def InitializeTCP(host_port):
    
    ValidIpAddressRegex = re.compile("^((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])):(\d+)$");
    ValidHostnameRegex = re.compile("^((([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])):(\d+)$");

    if ValidIpAddressRegex.search(host_port) is None and \
        ValidHostnameRegex.search(host_port) is None:
        return False

    match = ValidIpAddressRegex.search(host_port) or ValidHostnameRegex.search(host_port)
    groups = match.groups()
    ser = tcp_wrapper()
    host, port = groups[0], groups[4]
    sys.stdout.write("connecting to %s:%s..." % (host, port))
    sys.stdout.flush()
    ser.connect(host, int(port))
    print("connected")

    global outp, inp
    outp = ser
    inp = ser
    return True

def exit_gracefully(sig, frm):
    sys.exit(1)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, exit_gracefully)

    parser = argparse.ArgumentParser(description = 'Term for risc-v32 expirence.')
    parser.add_argument('-c', '--continued', action='store_true', help='Term will not wait for welcome if this flag is set')
    parser.add_argument('-t', '--tcp', default=None, help='TCP server address:port for communication')
    parser.add_argument('-s', '--serial', default=None, help='Serial port name (e.g. /dev/ttyACM0, COM3)')
    parser.add_argument('-b', '--baud', default=9600, help='Serial port baudrate (9600 by default)')
    args = parser.parse_args()

    if args.tcp:
        if not InitializeTCP(args.tcp):
            print('Failed to establish TCP connection')
            exit(1)
    elif args.serial:
        if not InitializeSerial(args.serial, args.baud):
            print('Failed to open serial port')
            exit(1)
    else:
        parser.print_help()
        exit(1)
    Main(not args.continued)
