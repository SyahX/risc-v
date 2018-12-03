ori x1, x0, 0
lui x2, 0x80400
sw x2, x2, 0
lw x3, x2, 0
sw x3, x3, 4
lw x4, x2, 0
sw x4, x4, 8
nop
nop
nop
nop
nop
jal x0, -2
