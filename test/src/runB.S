ori x1, x0, 0
lui x2, 0x80400
lw x3, x1, 0
sw x2, x3, 0
lw x3, x1, 4
sw x2, x3, 4
lw x3, x1, 8
sw x2, x3, 8
nop
jal x0, -2
