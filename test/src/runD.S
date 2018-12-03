lui x1, 0xBFD00
ori x1, x1, 0x3F8
lui x2, 0xBFD00
ori x2, x2, 0x3FC
lui x3, 0x80400
lb x4, x0, 0
lb x5, x0, 1
lb x6, x0, 2
lb x7, x0, 3
lb x8, x2, 0
sb x1, x8, 0
sb x1, x4, 0
sb x1, x5, 0
sb x1, x6, 0
sb x1, x7, 0
nop
nop
jal x0, -2
