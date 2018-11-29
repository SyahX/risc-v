    .section .text
    .p2align 2
.global _start
_start:
    ori t1, zero, 5
    ori t2, zero, 15
    add t3, t1, t2
    sub t4, t3, t1
    sll t3, t3, 2
    addi t5, t3, 10
    ori x0, x0, 1
    ori x0, x1, 1
    ori x1, x0, 1
    ori x2, x0, 2
    sub x3, x1, x2
    sub x3, x3, x3
    ori x4, x0, 15
    andi x5, x4, 27
    xor x6, x4, x5
    slti x7, x6, 4
    slti x7, x6, 5
    slti x7, x6, -1
    sltiu x7, x6, -1
    srli x7, x6, 1
    ori x8, x0, -31
    srli x7, x8, 4
    srai x7, x8, 4
