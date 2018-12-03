#include <exception.h>

.section .bss
.p2align 2
.global TCBT                        // thread control block table
TCBT:
    .long 0                         // address of thread 0
    .long 0                         // address of thread 1
.global current                     // current thread TCB address
current:
    .long 0

.text
.p2align 2
//monitor_version:
//    .asciz "MONITOR for RISC-V - initialized."
    .word _sbss                     # the start address of .bss, defined in linker script
    .word _ebss 
    .globl WELCOME                    # the end address of .bss, defined in linker script
    .globl START
START:
    lui s10, %hi(_sbss)
    addi s10, s10, %lo(_sbss)
    lui s11, %hi(_ebss)
    addi s11, s11, %lo(_ebss)

bss_init:
/* To init the .bss segment */
    beq s10, s11, bss_init_done
    nop
    sw  zero, 0(s10)
    addi s10, s10, 4
    j   bss_init
    nop

bss_init_done:
/* init .bss segment done */
    lui sp, %hi(KERNEL_STACK_INIT)  // 设置内核栈
    addi sp, sp, %lo(KERNEL_STACK_INIT)
    or s0, sp, zero
    lui t0, %hi(USER_STACK_INIT)    // 设置用户栈
    addi t0, t0, %lo(USER_STACK_INIT)
    lui t1, %hi(uregs_sp)           // 将寄存器fp和sp写入用户空间备份
    sw t0, %lo(uregs_sp)(t1)
    lui t1, %hi(uregs_fp)
    sw t0, %lo(uregs_fp)(t1)

#ifdef MACH_QEMU
/* see ucore/kern/driver/console.c */
/* init serial */
    lui t0, 0xBFD0                  // NOTE: all COM_* share high 16 bits
                                    // 0xBFD0 should be %hi(COM1) but can not be used
                                    // due to a compiler bug (bugzilla/20649)
    sb zero, %lo(COM_FCR)(t0)       // console.c:54
    ori t1, zero, %lo(COM_LCR_DLAB)
    sb t1, %lo(COM_LCR)(t0)         // :57
    ori t1, zero, %lo(COM_DLL_VAL)
    sb t1, %lo(COM_DLL)(t0)         // :58
    sb zero, %lo(COM_DLM)(t0)       // :59
    ori t1, zero, %lo(COM_LCR_CONFIG)
    sb t1, %lo(COM_LCR)(t0)         // :62
    sb zero, %lo(COM_MCR)(t0)       // :65
    ori t1, zero, %lo(COM_IER_RDI)
    sb t1, %lo(COM_IER)(t0)         // :67
#else
    lui t0, %hi(SerialStat)
    ori t1, zero, 0x10
    sb t1, %lo(SerialStat)(t0)      // 串口可读中断
#endif

    ori t0, zero, TF_SIZE / 4       // 计数器
.LC0:
    addi t0, t0, -1                // 滚动计数器
    addi sp, sp, -4                // 移动栈指针
    sw zero, 0(sp)                  // 初始化栈空间
    bne t0, zero, .LC0              // 初始化循环
    nop
    lui t0, %hi(TCBT)
    addi t0, t0, %lo(TCBT)          // 载入TCBT地址
    sw sp, 0(t0)                    // thread0(idle)的中断帧地址设置
    or t6, sp, zero                 // t6保存idle中断帧位置

    ori t0, zero, TF_SIZE / 4       // 计数器
.LC1:
    addi t0, t0, -1                 // 滚动计数器
    addi sp, sp, -4                 // 移动栈指针
    sw zero, 0(sp)                  // 初始化栈空间
    bne t0, zero, .LC1              // 初始化循环
    nop
    lui t0, %hi(TCBT)
    addi t0, t0, %lo(TCBT)           // 载入TCBT地址
    sw sp, 4(t0)                    // thread1(shell/user)的中断帧地址设置
    sw sp, TF_sp(t6)                // 设置idle线程栈指针(调试用?)

    lui t2, %hi(TCBT + 4)
    addi t2, t2, %lo(TCBT + 4)
    lw t2, 0(t2)                    // 取得thread1的TCB地址
    lui t1, %hi(current)
    sw t2, %lo(current)(t1)         // 设置当前线程为thread1

    j WELCOME                       // 进入主线程
    nop

WELCOME:
1:  ori a0, zero, 0x4d              // 'M'
    jal WRITESERIAL
    nop
2:  ori a0, zero, 0x4f              // 'O'
    jal WRITESERIAL
    nop
3:  ori a0, zero, 0x4e              // 'N'
    jal WRITESERIAL
    nop
4:  ori a0, zero, 0x49              // 'I'
    jal WRITESERIAL
    nop
5:  ori a0, zero, 0x54              // 'T'
    jal WRITESERIAL
    nop
6:  ori a0, zero, 0x4f              // 'O'
    jal WRITESERIAL
    nop
7:  ori a0, zero, 0x52              // 'R'
    jal WRITESERIAL
    nop
8:  ori a0, zero, 0x20              // ' '
    jal WRITESERIAL
    nop
9:  ori a0, zero, 0x66              // 'f'
    jal WRITESERIAL
    nop
10: ori a0, zero, 0x6f              // 'o'
    jal WRITESERIAL
    nop
11: ori a0, zero, 0x72              // 'r'
    jal WRITESERIAL
    nop
12: ori a0, zero, 0x20              // ' '
    jal WRITESERIAL
    nop
13: ori a0, zero, 0x52              // 'R'
    jal WRITESERIAL
    nop
14: ori a0, zero, 0x49              // 'I'
    jal WRITESERIAL
    nop
15: ori a0, zero, 0x53              // 'S'
    jal WRITESERIAL
    nop
16: ori a0, zero, 0x43              // 'C'
    jal WRITESERIAL
    nop
17: ori a0, zero, 0x2d              // '-'
    jal WRITESERIAL
    nop
18: ori a0, zero, 0x56              // 'v'
    jal WRITESERIAL
    nop
19: ori a0, zero, 0x20              // ' '
    jal WRITESERIAL
    nop
20: ori a0, zero, 0x2d              // '-'
    jal WRITESERIAL
    nop
21: ori a0, zero, 0x20              // ' '
    jal WRITESERIAL
    nop
22: ori a0, zero, 0x69              // 'i'
    jal WRITESERIAL
    nop
23: ori a0, zero, 0x6e              // 'n'
    jal WRITESERIAL
    nop
24: ori a0, zero, 0x69              // 'i'
    jal WRITESERIAL
    nop
25: ori a0, zero, 0x74              // 't'
    jal WRITESERIAL
    nop
26: ori a0, zero, 0x69              // 'i'
    jal WRITESERIAL
    nop
27: ori a0, zero, 0x61              // 'a'
    jal WRITESERIAL
    nop
28: ori a0, zero, 0x6c              // 'l'
    jal WRITESERIAL
    nop
29: ori a0, zero, 0x69              // 'i'
    jal WRITESERIAL
    nop
30: ori a0, zero, 0x7a              // 'z'
    jal WRITESERIAL
    nop
31: ori a0, zero, 0x65              // 'e'
    jal WRITESERIAL
    nop
32: ori a0, zero, 0x64              // 'd'
    jal WRITESERIAL
    nop
33: ori a0, zero, 0x2e              // '.'
    jal WRITESERIAL
    nop
    lui s3, 0x80500                 // DEBUG
    j SHELL                         // 开始交互
    nop

IDLELOOP:
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    j IDLELOOP
    nop
