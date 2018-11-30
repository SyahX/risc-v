ori t0, zero, 5
ori t1, zero, 5
ori t3, zero, 7
ori t5, zero, 1
beq t0, t1, 0xfff
ori t4, zero, 1
addi t3, t3, 1
sub t4, t3, t5
bne t3, t4, -4 
lw t3, t4, 10
blt t3, t4, -2
nop