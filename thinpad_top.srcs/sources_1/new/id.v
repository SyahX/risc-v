`timescale 1ns / 1ps

`include "defines.v"

module id (
	input wire rst,

	input wire[`InstAddrBus]	pc_i,
	input wire[`InstBus]		inst_i,

	// get data from regfile
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,					

	// output pc
	output reg[`InstAddrBus]	pc_o,

	// para to regfile
	output reg[`RegBus]			reg1_data_o,
	output reg[`RegBus]			reg2_data_o,
	output reg[`RegAddrBus]		reg1_addr_o,
	output reg[`RegAddrBus] 	reg2_addr_o,

	// imm gen
	output reg[`ImmBus]			imm_data_o,

	// inst for ALU
	output reg 					alu_lr_o,
	output reg[`AluOpBus]		alu_op_o,
	
	// write register
	output reg[`RegAddrBus]		write_addr_o,

	// branch pc
	output reg[`InstAddrBus]	branch_pc_o
);
	
	wire[6:0] op = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];

	// register
	always @ (*) begin
		pc_o <= pc_i;

		reg1_data_o <= reg1_data_i;
		reg2_data_o <= reg2_data_i;

		reg1_addr_o <= inst_i[19:15];
		reg2_addr_o <= inst_i[24:20];

		branch_pc_o <= {19'b0, inst_i[31:20], 1'b0} + pc_i;
	end

	// Alu
	always @ (*) begin
		if (op == `Itype) begin
			imm_data_o <= {20'b0, inst_i[31:20]};

			alu_lr_o <= 0;
			alu_op_o <= funct3;

			write_addr_o <= inst_i[11:7];
		end
	end

endmodule