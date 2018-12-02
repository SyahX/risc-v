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
import ctypes
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

inst_n = 37
itype_r = 0
itype_i = 1
itype_s = 2
itype_b = 3
itype_u = 4
itype_j = 5
itype_f = 6

Reg_name2index = {
    'zero' : 0,
    'ra'   : 1,
    'sp'   : 2,
    'gp'   : 3,
    'tp'   : 4,
    't0'   : 5,
    't1'   : 6,
    't2'   : 7,
    's0'   : 8,
    'fp'   : 8,
    's1'   : 9,
    'a0'   : 10,
    'a1'   : 11,
    'a2'   : 12,
    'a3'   : 13,
    'a4'   : 14,
    'a5'   : 15,
    'a6'   : 16,
    'a7'   : 17,
    's2'   : 18,
    's3'   : 19,
    's4'   : 20,
    's5'   : 21,
    's6'   : 22,
    's7'   : 23,
    's8'   : 24,
    's9'   : 25,
    's10'  : 26,
    's11'  : 27,
    't3'   : 28,
    't4'   : 29,
    't5'   : 30,
    't6'   : 31,
    'x0'   : 0,
    'x1'   : 1,
    'x2'   : 2,
    'x3'   : 3,
    'x4'   : 4,
    'x5'   : 5,
    'x6'   : 6,
    'x7'   : 7,
    'x8'   : 8,
    'x9'   : 9,
    'x10'  : 10,
    'x11'  : 11,
    'x12'  : 12,
    'x13'  : 13,
    'x14'  : 14,
    'x15'  : 15,
    'x16'  : 16,
    'x17'  : 17,
    'x18'  : 18,
    'x19'  : 19,
    'x20'  : 20,
    'x21'  : 21,
    'x22'  : 22,
    'x23'  : 23,
    'x24'  : 24,
    'x25'  : 25,
    'x26'  : 26,
    'x27'  : 27,
    'x28'  : 28,
    'x29'  : 29,
    'x30'  : 30,
    'x31'  : 31,
}

inst_struct = {
    "lui"   : [itype_u, 0b0110111, 0    , 0],
    "auipc" : [itype_u, 0b0010111, 0    , 0],
    "jal"   : [itype_j, 0b1101111, 0    , 0],
    "jalr"  : [itype_i, 0b1100111, 0    , 0],
    "beq"   : [itype_b, 0b1100011, 0b000, 0],
    "bne"   : [itype_b, 0b1100011, 0b001, 0],
    "blt"   : [itype_b, 0b1100011, 0b100, 0],
    "bge"   : [itype_b, 0b1100011, 0b101, 0],
    "bltu"  : [itype_b, 0b1100011, 0b110, 0],
    "bgeu"  : [itype_b, 0b1100011, 0b111, 0],
    "lb"    : [itype_i, 0b0000011, 0b000, 0],
    "lh"    : [itype_i, 0b0000011, 0b001, 0],
    "lw"    : [itype_i, 0b0000011, 0b010, 0],
    "lbu"   : [itype_i, 0b0000011, 0b100, 0],
    "lhu"   : [itype_i, 0b0000011, 0b101, 0],
    "sb"    : [itype_s, 0b0100011, 0b000, 0],
    "sh"    : [itype_s, 0b0100011, 0b001, 0],
    "sw"    : [itype_s, 0b0100011, 0b010, 0],
    "addi"  : [itype_i, 0b0010011, 0b000, 0],
    "slti"  : [itype_i, 0b0010011, 0b010, 0],
    "sltiu" : [itype_i, 0b0010011, 0b011, 0],
    "xori"  : [itype_i, 0b0010011, 0b100, 0],
    "ori"   : [itype_i, 0b0010011, 0b110, 0],
    "andi"  : [itype_i, 0b0010011, 0b111, 0],
    "slli"  : [itype_r, 0b0010011, 0b001, 0b0000000],
    "srli"  : [itype_r, 0b0010011, 0b101, 0b0000000],
    "srai"  : [itype_r, 0b0010011, 0b101, 0b0100000],
    "add"   : [itype_r, 0b0110011, 0b000, 0b0000000],
    "sub"   : [itype_r, 0b0110011, 0b000, 0b0000000],
    "sll"   : [itype_r, 0b0110011, 0b001, 0b0000000],
    "slt"   : [itype_r, 0b0110011, 0b010, 0b0000000],
    "sltu"  : [itype_r, 0b0110011, 0b011, 0b0000000],
    "xor"   : [itype_r, 0b0110011, 0b100, 0b0000000],
    "srl"   : [itype_r, 0b0110011, 0b101, 0b0000000],
    "sra"   : [itype_r, 0b0110011, 0b101, 0b0100000],
    "or"    : [itype_r, 0b0110011, 0b110, 0b0000000],
    "and"   : [itype_r, 0b0110011, 0b111, 0b0000000],
    "nop"   : [itype_i, 0x13]
}



# convert 32-bit int to byte string of length 4, from LSB to MSB
def int_to_byte_string(val):
    return struct.pack('<I', val)

def byte_string_to_int(val):
    return struct.unpack('<I', val)[0]

def inst2int(instr):
    instr = instr.lower()
    component = re.split(r' *, *|\s*,\s*| +| *\n', instr)
    # print(component)
    res = 0
    k = 0
    if component[k] in inst_struct:
        if component[k] == "nop":
            res = inst_struct["nop"][1]
            return int_to_byte_string(res)
        ins_key = inst_struct[component[0]]
        # print(ins_key)
        k += 1
        res = ins_key[1]
        # print("res: " + str(bin(res)))
        if ins_key[0] == itype_r or ins_key[0] == itype_i or ins_key[0] == itype_s or ins_key[0] == itype_b:
            res = (ins_key[2] << 12) + res
            # print("res: " + str(bin(res)))
        if ins_key[0] == itype_r:
            res = (ins_key[3] << 25) + res
        if ins_key[0] == itype_r or ins_key[0] == itype_i or ins_key[0] == itype_u or ins_key[0] == itype_j:
            rd = -1
            if component[k] in Reg_name2index:
                rd = Reg_name2index[component[1]]
                # print("rd: " + str(rd))
                res = (rd << 7) + res
            else:
                print("Register name %s can not found, try another name! " % component[k])
                return ''
            k += 1
            # print("res: " + str(bin(res)))
        if ins_key[0] == itype_r or ins_key[0] == itype_i or ins_key[0] == itype_s or ins_key[0] == itype_b:
            rs1 = -1
            if component[k] in Reg_name2index:
                rs1 = Reg_name2index[component[k]]
                res = (rs1 << 15) + res
                # print("rs1: " + str(rs1))
            else:
                print("Register name %s can not found, try another name! " % component[k])
                return ''
            k += 1
            # print("res: " + str(bin(res)))
        if ins_key[0] == itype_r or ins_key[0] == itype_b or ins_key[0] == itype_s:
            rs2 = -1
            if ins_key[1] == 0b0010011:
                try:
                    if "x" in component[k]:
                        rs2 = ctypes.c_uint(int(component[k][2:], 16)).value
                    else:
                        rs2 = ctypes.c_uint(int(component[k])).value
                    res = res + (rs2 << 20)
                except ValueError:
                    print("Immediate number is not right")
                    return ''
            elif component[k] in Reg_name2index:
                rs2 = Reg_name2index[component[k]]
                res = res + (rs2 << 20)
            else:
                print("Register name %s can not found, try another name! " % component[k])
                return ''
            # print("rs2: " + str(rs2))
            k += 1
            # print("res: " + str(bin(res)))
        if ins_key[0] != itype_r:
            try:
                if "x" in component[k]:
                    imm = ctypes.c_uint(int(component[k][2:], 16)).value
                else:
                    imm = ctypes.c_uint(int(component[k])).value
                # print("immediate %d" % imm)
            except ValueError:
                print("Immediate number is not right")
                return ''
            k += 1
            if ins_key[0] == itype_i:
                res = res + ((imm & 0xfff) << 20)
            if ins_key[0] == itype_s:
                res = res + ((imm & 0x1f) << 7)
                imm = imm >> 5
                res = res + ((imm & 0x7f) << 25)
            if ins_key[0] == itype_b:
                # imm = imm >> 1
                res = res + ((imm & 0xf) << 8)
                imm = imm >> 4
                res = res + ((imm & 0x3f) << 25)
                imm = imm >> 6
                res = res + ((imm & 0x1) << 7)
                imm = imm >> 1
                res = res + ((imm & 0x1) << 31)
            if ins_key[0] == itype_u:
                # imm = imm >> 12
                res = res + ((imm & 0xfffff) << 12)
            if ins_key[0] == itype_j:
                # imm = imm >> 1
                res = res + ((imm & 0x3ff) << 21)
                imm = imm >> 10
                res = res + ((imm & 0x1) << 20)
                imm = imm >> 1
                res = res + ((imm & 0xff) << 12)
                imm = imm >> 8
                res = res + ((imm & 0x1) << 31)
    if res != 0:
        return int_to_byte_string(res)
    else:
        print("Cannot find the instruction %s" % component[0])
        return ''
            


# invoke assembler to encode single instruction (in risc-v 32i)
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
            # instr = single_line_asm(line)
            instr = inst2int(line)
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
            sys.stdout.buffer.write(ret)
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
        print(inp.read(1))
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
