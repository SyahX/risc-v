//#include <regdef.h>
//#include <mipsregs.h> 
#include <shell.h>

//    .set noreorder
//    .set noat

    .section .bss.uregs
    .p2align 2
    .global uregs
uregs:                              // 通用寄存器组
    .rept 32                        // 第1个为用户程序入口地址临时保存
    .long 0
    .endr

    .text
    .p2align 2
    .global SHELL

    /*
     *  SHELL: 监控程序交互模块
     * 
     *  用户空间寄存器：x1-x31依次保存在0x807F0000连续124字节
     *  用户程序入口临时存储：0x807F0000
     */
SHELL:
    jal READSERIAL                  // 读操作符
    nop

    ori t0, zero, SH_OP_R
    beq t5, t0, .OP_R
    nop
    ori t0, zero, SH_OP_D
    beq t5, t0, .OP_D
    nop
    ori t0, zero, SH_OP_A
    beq t5, t0, .OP_A
    nop
    ori t0, zero, SH_OP_G
    beq t5, t0, .OP_G
    nop
    j .DONE                         // 错误的操作符，默认忽略
    nop

.OP_R:                              // 操作 - 打印用户空间寄存器
    addi sp, sp, -8                 // 保存s1,s2
    sw s1, 0(sp)
    sw s2, 4(sp)

    lui s1, %hi(uregs)
    ori s2, zero, 124               // 计数器，打印124字节
.LC0:
    lb a0, %lo(uregs)(s1)           // 读取字节
    addi s2, s2, -1                 // 滚动计数器
    jal WRITESERIAL                 // 写入串口
    nop
    addi s1, s1, 0x1                // 移动打印指针
    bne s2, zero, .LC0              // 打印循环
    nop

    lw s1, 0(sp)                    // 恢复s1,s2
    lw s2, 4(sp)
    addi sp, sp, 8
    j .DONE
    nop

.OP_D:                              // 操作 - 打印内存num字节
    addi sp, sp, -8                 // 保存s1,s2
    sw s1, 0(sp)
    sw s2, 4(sp)

    jal READSERIALWORD
    nop
    or s1, t5, zero                 // 获得addr
    jal READSERIALWORD
    nop
    or s2, t5, zero                 // 获得num

.LC1:
    lb a0, 0(s1)                    // 读取字节
    addi s2, s2, -1                 // 滚动计数器
    jal WRITESERIAL                 // 写入串口
    nop
    addi s1, s1, 0x1                // 移动打印指针
    bne s2, zero, .LC1              // 打印循环
    nop

    lw s1, 0(sp)                    // 恢复s1,s2
    lw s2, 4(sp)
    addi sp, sp, 8
    j .DONE
    nop

.OP_A:                              // 操作 - 写入内存num字节，num为4的倍数
    addi sp, sp, -8                 // 保存s1,s2
    sw s1, 0(sp)
    sw s2, 4(sp)

    jal READSERIALWORD
    nop
    or s1, t5, zero                 // 获得addr
    jal READSERIALWORD
    nop
    or s2, t5, zero                 // 获得num
    srl s2, s2, 2                   // num除4，获得字数
.LC2:                               // 每次写入一字
    jal READSERIALWORD              // 从串口读入一字
    nop
    sw t5, 0(s1)                    // 写内存一字
    addi s2, s2, -1                 // 滚动计数器
    addi s1, s1, 4                  // 移动写指针
    bne s2, zero, .LC2              // 写循环
    nop

    lw s1, 0(sp)                    // 恢复s1,s2
    lw s2, 4(sp)
    addi sp, sp, 8
    j .DONE
    nop

.OP_G:
    jal READSERIALWORD              // 获取addr
    nop

    ori a0, zero, TIMERSET          // 写TIMERSET(0x06)信号
    jal WRITESERIAL                 // 告诉终端用户程序开始运行
    nop

    or s10, t5, zero                 // 用户程序入口写入s9寄存器
    lui ra, %hi(uregs)              // 定位用户空间寄存器备份地址
    addi ra, ra, %lo(uregs)
    sw t5, PUTREG(1)(ra)           // 保存用户程序入口
    sw sp, PUTREG(32)(ra)           // 保存栈指针

    //lw x1,  PUTREG(1)(ra)
    lw x2,  PUTREG(2)(ra)          // 装入x2-x31
    lw x3,  PUTREG(3)(ra)
    lw x4,  PUTREG(4)(ra)
    lw x5,  PUTREG(5)(ra)
    lw x6,  PUTREG(6)(ra)
    lw x7,  PUTREG(7)(ra)
    lw x8,  PUTREG(8)(ra)
    lw x9,  PUTREG(9)(ra)
    lw x10, PUTREG(10)(ra)
    lw x11, PUTREG(11)(ra)
    lw x12, PUTREG(12)(ra)
    lw x13, PUTREG(13)(ra)
    lw x14, PUTREG(14)(ra)
    lw x15, PUTREG(15)(ra)
    lw x16, PUTREG(16)(ra)
    lw x17, PUTREG(17)(ra)
    lw x18, PUTREG(18)(ra)
    lw x19, PUTREG(19)(ra)
    lw x20, PUTREG(20)(ra)
    lw x21, PUTREG(21)(ra)
    lw x22, PUTREG(22)(ra)
    lw x23, PUTREG(23)(ra)
    lw x24, PUTREG(24)(ra)
    lw x25, PUTREG(25)(ra)
    //lw x26, PUTREG(26)(ra)
    //lw x27, PUTREG(27)(ra)
    lw x28, PUTREG(28)(ra)
    lw x29, PUTREG(29)(ra)
    lw x30, PUTREG(30)(ra)
    lw x31, PUTREG(31)(ra)

    lui ra, %hi(.USERRET2)          // ra写入返回地址
    addi ra, ra, %lo(.USERRET2)
    nop

    jr s10
    nop                             //运行用户程序

.USERRET2:
    nop

    lui ra, %hi(uregs)              // 定位用户空间寄存器备份地址
    addi ra, ra, %lo(uregs)

    //sw x1,  PUTREG(1)(ra)
    sw x2,  PUTREG(2)(ra)           // 备份x2-x31
    sw x3,  PUTREG(3)(ra)
    sw x4,  PUTREG(4)(ra)
    sw x5,  PUTREG(5)(ra)
    sw x6,  PUTREG(6)(ra)
    sw x7,  PUTREG(7)(ra)
    sw x8,  PUTREG(8)(ra)
    sw x9,  PUTREG(9)(ra)
    sw x10, PUTREG(10)(ra)
    sw x11, PUTREG(11)(ra)
    sw x12, PUTREG(12)(ra)
    sw x13, PUTREG(13)(ra)
    sw x14, PUTREG(14)(ra)
    sw x15, PUTREG(15)(ra)
    sw x16, PUTREG(16)(ra)
    sw x17, PUTREG(17)(ra)
    sw x18, PUTREG(18)(ra)
    sw x19, PUTREG(19)(ra)
    sw x20, PUTREG(20)(ra)
    sw x21, PUTREG(21)(ra)
    sw x22, PUTREG(22)(ra)
    sw x23, PUTREG(23)(ra)
    sw x24, PUTREG(24)(ra)
    sw x25, PUTREG(25)(ra)
    //sw x26, PUTREG(26)(ra)
    //sw x27, PUTREG(27)(ra)
    sw x28, PUTREG(28)(ra)
    sw x29, PUTREG(29)(ra)
    sw x30, PUTREG(30)(ra)
    sw x31, PUTREG(31)(ra)

    lw sp, PUTREG(32)(ra)           // 重新获得当前监控程序栈顶指针
    ori a0, zero, TIMETOKEN         // 发送TIMETOKEN(0x07)信号
    jal WRITESERIAL                 // 告诉终端用户程序结束运行
    nop

    j .DONE
    nop

.DONE:
    j SHELL                         // 交互循环
    nop
