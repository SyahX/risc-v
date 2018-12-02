lui x1, 0xBFD00
ori x1, x1, 0x3F8
lui x2, 0xBFD00
ori x2, x2, 0x3FC
lb x30, x2, 0
sw x0, x30, 4
ori x2, x0, 0x1a
sb x1, x2, 0
ori x2, x0, 0x2b
sb x1, x2, 0
ori x2, x0, 0x3d
sb x1, x2, 0
ori x2, x0, 0x4d
sb x1, x2, 0
sw x0, x30, 16
sw x0, x0, 0
sw x0, x0, 8
sw x0, x0, 12
