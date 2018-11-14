`timescale 1ns / 1ps

`include "defines.v"

module id_ex (
	input wire clk,
	input wire rst,
	
	// control input 
	input wire					ctrl_wb_RegWrite_i,
	input wire					ctrl_wb_Mem2Reg_i,
	input wire 					ctrl_mem_branch_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,
	input wire					ctrl_ex_AluSrc_i,
	input wire[1:0] 			ctrl_ex_AluOp_i,

	// input pc
	input wire[`InstAddrBus]	pc_i,

	// input register data
	input wire[`RegBus]			reg1_data_i,
	input wire 					reg2_ce_i,
	input wire[`RegBus]			reg2_data_i,
	
	// input of imm
	input wire					imm_ce_i,
	input wire[`ImmBus]			imm_data_i,

	// input ALU ctrl 
	input wire					alu_lr_i,
	input wire[`AluOpBus]		alu_op_i,

	// input of register write addr
	input wire[`RegAddrBus]		write_addr_i,

	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg 					ctrl_mem_branch_o,
	output reg 					ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,
	output reg					ctrl_ex_AluSrc_o,
	output reg[1:0] 			ctrl_ex_AluOp_o,

	// output pc
	output reg[`InstAddrBus]	pc_o,

	// output register data
	output reg[`RegBus]			reg1_data_o,
	output reg 					reg2_ce_o,
	output reg[`RegBus]			reg2_data_o,
	
	// output of imm
	output reg					imm_ce_o,
	output reg[`ImmBus]			imm_data_o,

	// output ALU ctrl 
	output reg					alu_lr_o,
	output reg[`AluOpBus]		alu_op_o,

	// output of register write addr
	output reg[`RegAddrBus]		write_addr_o,
);

	always @ (posedge clk) 
	begin
		if (rst == `Asserted) 
		begin
			
		end
		else
		begin
			ctrl_wb_RegWrite_o <= ctrl_wb_RegWrite_i;
			ctrl_wb_Mem2Reg_o <= ctrl_wb_Mem2Reg_i;
			ctrl_mem_branch_o <= ctrl_mem_branch_i;
			ctrl_mem_read_o <= ctrl_mem_read_i;
			ctrl_mem_write_o <= ctrl_mem_write_i;				
			ctrl_ex_AluSrc_o <=	ctrl_ex_AluSrc_i;		
			ctrl_ex_AluOp_o <= ctrl_ex_AluOp_i;

			pc_o <= pc_i;

			reg1_data_o <= reg1_data_i;
			reg2_ce_o <= reg2_ce_i;
			reg2_data_o <= reg2_data_i;

			imm_ce_o <= imm_ce_i;
			imm_data_o <= imm_data_i;

			alu_lr_o <= alu_lr_i;
			alu_op_o <= alu_op_i;

			write_addr_o <= write_addr_i;
		end
	end

endmodule