`timescale 1ns / 1ps

`include "defines.v"

module control (
	input wire rst,

	input wire[`InstBus]		inst_i,

	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg 					ctrl_mem_branch_o,
	output reg 					ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,
	output reg					ctrl_ex_AluSrc_o, 
	output reg[`AluOpBus] 		ctrl_ex_AluOp_o
);
	wire[6:0] op = inst_i[6:0];
	wire[2:0] funct3 = inst_i[14:12];
	wire[6:0] funct7 = inst_i[31:25];

	always @ (*) begin
		if (rst == `Asserted) begin
			ctrl_wb_RegWrite_o <= `DeAsserted;
			ctrl_wb_Mem2Reg_o <= `DeAsserted;
			ctrl_mem_branch_o <= `DeAsserted;
			ctrl_mem_read_o <= `DeAsserted;
			ctrl_mem_write_o <= `DeAsserted;
			ctrl_ex_AluSrc_o <= `DeAsserted;
			ctrl_ex_AluOp_o <= 3'b000;
		end
		else begin
			//ori
			if ((op == `Itype) && (funct3 == 3'b110)) begin
				ctrl_wb_RegWrite_o <= `DeAsserted;
				ctrl_wb_Mem2Reg_o <= `Asserted;
				ctrl_mem_branch_o <= `DeAsserted;
				ctrl_mem_read_o <= `DeAsserted;
				ctrl_mem_write_o <= `DeAsserted;
				ctrl_ex_AluSrc_o <= `Asserted;
				ctrl_ex_AluOp_o <= 3'b110;
			end
		end
	end

endmodule