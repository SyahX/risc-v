# Supervisor For RISC-V

32位RISC-V监控程序

## 依赖库

riscv-gnu-toolchain(32位)，可以在Github上下载得到(https://github.com/riscv/riscv-gnu-toolchain)。

## Kernel

对应kern文件夹下的汇编代码，通过Makefile完成编译过程并生成对应的二进制代码，即可以在CPU上运行的监控代码。其使用到的代码条数为16条，且都符合RV32I的准则。本次的kernel仅有一个版本，不支持中断和异常，可以留作之后的进阶项目。

1. `lui`  iiiiiiiiiiiiiiiiiiiittttt0110111
2. `jal`  iiiiiiiiiiiiiiiiiiiittttt1101111
3. `jalr` iiiiiiiiiiiisssss000ttttt1100111
4. `beq`  iiiiiiidddddsssss000iiiii1100011
5. `bne`  iiiiiiidddddsssss001iiiii1100011
6. `lb`   iiiiiiiiiiiisssss000ttttt0000011
7. `lw`   iiiiiiiiiiiisssss010ttttt0000011
8. `sb`   iiiiiiidddddsssss000iiiii0100011
9. `sw`   iiiiiiidddddsssss010iiiii0100011
10. `addi` iiiiiiiiiiiisssss000ttttt0010011
11. `ori`  iiiiiiiiiiiisssss110ttttt0010011
12. `andi` iiiiiiiiiiiisssss111ttttt0010011
13. `slli` 0000000iiiiisssss001ttttt0010011
14. `srli` 0000000iiiiisssss101ttttt0010011
15. `xor`  0000000dddddsssss100ttttt0110011
16. `or`   0000000dddddsssss110ttttt0110011

### 使用方法

建议使用上述提到的32位gnu-tool进行编译。下载安装完成后，修改Makefile中riscv-gnu-toolchain的路径，之后执行`make ON_FPGA=y`会生成二进制文件kernel.bin，即可作为CPU的监控运行。此外Makefile还提供了一些其他的指令，详细见下：

+ `make ON_FPGA=y`：生成kernel的二进制文件用于在CPU上执行。需要烧入32位板子的ExtRAM的00000地址，并将初始PC指向0x80000000地址，即可开始运行。
+ `make final`：生成汇编程序的反汇编语句用于查看每条指令的二进制编码和是否编译正确。
+ `make show-utest`：用于显示单元测试的地址，可以查看kernel内部定义的几个测试代码的位置。具体的测试代码可以在文件`kern/test.S`中查看。
+ `make clean`：用于删除生成的中间文件。

监控程序在开始运行之后会发送"MONITOR for RISC-V - initialized."到term，表明程序正确运行。

在SRAM中监控程序使用了1M的空间，ExtRAM中剩余3M空间给用户代码。BaseRAM中监控程序数据占用约64KB的空间，剩下空间为用户数据空间，其中保留了16个字节用于对应串口的操作，具体的地址划分可以参照下面的表格。

### 地址划分

监控程序使用了 8 MB 的内存空间，其中约 1 MB 由 Kernel 使用，剩下的空间留给用户程序。此外，为了支持串口通信，还设置了一个内存以外的地址区域，用于串口收发。具体内存地址的分配方法如下表所示：

| 虚地址空间             | 说明       |
|:--------------------:|:---------:|
|0x80000000-0x800FFFFF |监控程序代码 |
|0x80100000-0x803FFFFF |用户程序代码 |
|0x80400000-0x807EFFFF |用户数据空间 |
|0x807F0000-0x807FFFFF |监控程序数据 |
|0xBFD003F8-0xBFD003FD |串口数据及状态|
串口控制器访问的代码位于`kern/utils.S`，其数据格式为：

| 地址       | 位    | 说明                                                 |
| ---------- | ----- | ---------------------------------------------------- |
| 0xBFD003F8 | [7:0] | 串口数据，读、写改地址表示通过串口接收、发送一个字节 |
| 0xBFD003FC | [0]   | 只读，为1时表示串口空闲，可以发送数据              |
| 0xBFD003FC | [1]   | 只读，为1时表示串口收到数据                      |

## Term

term.py需要通过python2运行，事先安装pyserial库用于串口通信。通过命令`python term.py`执行该文件。命令行函参数如下：

```
-c：term.py将不会接收welcome信息，用于调试bug，但需要手动修改kernel的汇编文件
-t：与网络平台的在线板子进行Tcp连接，指定地址和端口，用于交互通信
-s：用于指定串口，如在Ubuntu下的“/dev/ttyACM0”或者Windows下的”COM3”等
-b：用于指定串口通信的波特率，默认为9600
```

其中`-t`参数和`-s`参数必须提供一个，否则无法运行。

term主要用于个人电脑的终端与CPU的交互工作，本次的实验赵总Term提供了以下五个交互的操作码，分别对应的功能如下：

+ R：查看所有寄存器中的值
+ A：修改用户指定地址及之后的汇编代码，输入A之后首先输入要插入的地址，之后每行输入一条指令，若要退出，则连续两个回车即可。
+ D：以十六进制的方式打印从某个地址开始的n个字节。其中n由用户输入得到。
+ U：将从指定地址之后n个字节中得到的数据值进行反汇编得到对应的汇编代码。需要注意的是n需要是4的倍数。
+ G：执行指定位置处的代码。

Term中的U指令会用到gnu-tools尽心反汇编操作，其他指令不需要gnu-tools，所以在没有安装gnu-tools的情况下依然可以使用Term进行交互，但注意不要使用U指令。

## 参考文献

+ CPU采用的RISC-V32I指令集标准：risc-spec-v2.2.pdf

