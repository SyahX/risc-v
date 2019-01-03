ori t0, zero, 0
ori t1, zero, 1
ori t2, zero, 5
lui t3, 0x80200
sw t3, t0, 0
sw t3, t1, 4
addi t3, t3, 8
add t0, t0, t1
add t1, t0, t1
subi t2, t2, 1
bge t2, zero, -12
jalr zero, ra, 0