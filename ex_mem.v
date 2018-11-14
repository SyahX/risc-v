`timescale 1ns / 1ps

`include "defines.v"

module ex_mem (
	input wire clk,
	input wire rst,
	
	// control input 
	input wire					ctrl_wb_RegWrite_i,
	input wire					ctrl_wb_Mem2Reg_i,
	input wire 					ctrl_mem_branch_i,
	input wire 					ctrl_mem_read_i,
	input wire 					ctrl_mem_write_i,

	// intput branch pc 
	input wire					branch_ce_i,
	input wire[`InstAddrBus]	branch_pc_i,

	// input alu result
	input wire[`RegBus]			alu_result_i,

	// input write mem data
	input wire[`RegBus]			mem_write_data_i,

	// input of register write addr
	input wire[`RegAddrBus]		write_addr_i,

	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,
	output reg 					ctrl_mem_branch_o,
	output reg 					ctrl_mem_read_o,
	output reg 					ctrl_mem_write_o,

	// output branch pc 
	output reg					branch_ce_o,
	output reg[`InstAddrBus]	branch_pc_o,

	// output alu result
	output reg[`RegBus]			alu_result_o,

	// output write mem data
	output reg[`RegBus]			mem_write_data_o,

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
			ctrl_wb_RegWrite_i <= ctrl_wb_RegWrite_o;
			ctrl_wb_Mem2Reg_i <= ctrl_wb_Mem2Reg_o;
			ctrl_mem_branch_i <= ctrl_mem_branch_o;
			ctrl_mem_read_i <= ctrl_mem_read_o;
			ctrl_mem_write_i <= ctrl_mem_write_o;				

			branch_ce_i <= branch_ce_o;
			branch_pc_i <= branch_pc_o;

			alu_result_i <= alu_result_o;

			mem_write_data_i <= mem_write_data_o;

			write_addr_i <= write_addr_o;
		end
	end

endmodule