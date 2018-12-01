lui x1, 0xBFD00
ori x1, x1, 0x3F8
lui x2, 0xBFD00
ori x2, x2, 0x3FC
ori x3, x0, 0x3d
ori x4, x0, 0x26
sb x1, x3, 0
sw x0, x4, 0
lb x30, x1, 0
lb x30, x2, 0
lw x30, x0, 0
