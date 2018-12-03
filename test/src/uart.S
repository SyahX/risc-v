lui x1, 0xBFD00
ori x1, x1, 0x3F8
lui x2, 0xBFD00
ori x2, x2, 0x3FC
ori x4, x0, 0
lbu x3, x1, 0
add x4, x4, x3
lui x20, 0x80400
sw x20, x4, 0
sw x20, x3, 0
sw x20, x0, 8
ori x8, x0, 0x3c
sw x20, x8, 12
nop
jal x0, -2
