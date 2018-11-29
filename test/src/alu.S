    .section .text
    .p2align 2
.global _start
_start:
    ori t1, zero, 5
    nop 
    nop
    ori t2, zero, 15
    nop
    nop
    add t3, t1, t2
    nop
    nop
    sub t4, t3, t1
    nop
    nop
    sll t3, t3, 2
    nop
    nop
    addi t5, t3, 10
    nop
    nop
