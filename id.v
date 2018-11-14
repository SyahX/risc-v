`timescale 1ns / 1ps

`include "defines.v"

module id (
	input wire rst,

	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]		inst_i,

	// get data from regfile
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,

	// control
	output reg[`InstBus]		inst_ctrl_o, 					

	// output pc
	output reg[`InstAddrBus]	pc_o,

	// para to regfile
	output reg[`RegBus]			reg1_data_o,
	output reg 					reg2_ce_o,
	output reg[`RegBus]			reg2_data_o,
	output reg[`RegAddrBus]		reg1_addr_o,
	output reg[`RegAddrBus] 	reg2_addr_o,

	// imm gen
	output reg 					imm_ce_o,
	output reg[`ImmBus]			imm_data_o,

	// inst for ALU
	output reg 					alu_lr_o,
	output reg[`AluOpBus]		alu_op_o,
	
	// write register
	output reg[`RegAddrBus]		write_addr_o
);



endmodule