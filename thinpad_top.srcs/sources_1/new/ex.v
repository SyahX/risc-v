`timescale 1ns / 1ps

`include "defines.v"

module ex (
	input wire rst,

	// input control
	input wire 					ctrl_ex_AluSrc_i,

	// input alu
	input wire[`AluCtrlBus] 	alu_ctrl_i,
	
	// input of pc
	input wire[`InstAddrBus]	pc_i,

	// input resgiter
	input wire[`RegBus]			reg1_data_i,
	input wire[`RegBus]			reg2_data_i,

	// input imm
	input wire[`ImmBus]			imm_data_i,

	// output branch pc 
	output reg[`InstAddrBus]	branch_pc_o,

	// output alu result
	output reg 					alu_branch_take_o,
	output reg[`RegBus]			alu_result_o,

	// output write mem data
	output reg[`RegBus]			mem_write_data_o
);
    wire[`RegBus] reg1;
    reg[`RegBus] reg2;
	assign reg1 = reg1_data_i;
	
	always @ (*) begin
		branch_pc_o <= pc_i + (imm_data_i << 1);
		mem_write_data_o <= reg2_data_i;

		if (ctrl_ex_AluSrc_i == `Asserted) begin
			reg2 <= imm_data_i[`RegBus];
		end
		else begin
			reg2 <= reg2_data_i[`RegBus];
		end

		case (alu_ctrl_i)
			`EXE_OR : begin
				alu_branch_take_o <= 0;
				alu_result_o <= reg1 | reg2;
			end
			default : begin
				alu_branch_take_o <= 0;
				alu_result_o <= `ZeroWord;
			end
		endcase
	end

endmodule