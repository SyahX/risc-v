// You don't have to care about this file if you don't enable interrupt and TLB.

//    .set noreorder
//    .set noat
    .p2align 2
    .section .text.init
INITLOCATE:                         // 定位启动程序
    lui s10, %hi(WELCOME)
    addi s10, s10, %lo(WELCOME)
    jr s10
    nop