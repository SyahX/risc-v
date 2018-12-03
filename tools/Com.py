import serial
import struct

def int_to_byte_string(val):
    return struct.pack('<I', val)

def byte_string_to_int(val):
	return struct.unpack('<I', val)[0]

if __name__ == "__main__":
    tty = serial.Serial(port="/dev/ttyACM0", baudrate=9600)
    tty.reset_input_buffer()

    while(True):
        # print ("fuck")
        x = input("fuck : ")
        tty.write(int_to_byte_string(int(x))[0])
        print (hex(x))
