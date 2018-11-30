`timescale 1ns / 1ps

// all
`define Asserted 1'b1
`define DeAsserted 1'b0
`define ZeroWord 32'h00000000

// instruction
`define InstAddrBus 31:0
`define InstBus 31:0
`define InstMemNum 131071
`define InstMemNumLog2 17

// register
`define RegAddrBus 4:0
`define RegBus 31:0
`define RegNum 32
`define RegNumLog2 5

// imm
`define ImmBus 31:0

// ALU
`define AluOpBus 2:0
`define AluCtrlBus 3:0
`define CtrlAluOpBus 1:0

// ALU ctrl
`define EXE_ADD  4'b0000
`define EXE_SUB  4'b1000
`define EXE_SLL  4'b0001
`define EXE_SLT  4'b0010
`define EXE_SLTU 4'b0011
`define EXE_XOR  4'b0100
`define EXE_SRL  4'b0101
`define EXE_SRA  4'b1101
`define EXE_OR   4'b0110
`define EXE_AND  4'b0111
`define EXE_IMM  4'b1111

// inst type
`define Rtype 7'b0110011
`define Itype 7'b0010011
`define Btype 7'b1100011
`define Stype 7'b0100011
`define Ltype 7'b0000011
`define JALR  7'b1100111
`define JAL   7'b1101111
`define LUI   7'b0110111
`define AUIPC 7'b0010111

// funct3
`define BEQ 3'b000
`define BNE 3'b001
`define BLT 3'b100
`define BGE 3'b101
`define BLTU 3'b110
`define BGEU 3'b111

`define LB 3'b000
`define LH 3'b001
`define LW 3'b010
`define LBU 3'b100
`define LHU 3'b101

`define SB 3'b000
`define SH 3'b001
`define SW 3'b010

`define MemOpBus 2:0
`define RamAddrBus 19:0
