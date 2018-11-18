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
`define EXE_OR 4'b0110

// inst type
`define Rtype 7'b0110011
`define Itype 7'b0010011
