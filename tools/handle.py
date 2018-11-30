# -*- encoding=utf-8 -*-
import tempfile
import subprocess
import os, sys
import struct
import term

CCPREFIX = "/PATH/bin/riscv32-unknown-elf-"

def byte_string_to_int(val):
    return struct.unpack('<I', val)[0]

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

if __name__ == "__main__":
    # filename = input("Filename: ")
    filename = sys.argv[1]
    print (filename)
    ansname = filename.split('.S')[0] + ".data"
    ans = ""
    with open(filename, 'r') as assm:
        for (linenum, line) in enumerate(assm):
            if line.strip() == '':
                continue
            binary = term.inst2int(line)
            # print(term.single_line_disassmble(binary))
            machine = byte_string_to_int(binary)
            print(machine)
            ans = ans + "%08x" % machine + "\n"
    out = open(ansname, 'w')
    out.write(ans)
    out.close()
        
