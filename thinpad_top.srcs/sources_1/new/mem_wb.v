`timescale 1ns / 1ps

`include "defines.v"

module mem_wb (
	input wire rst,
	input wire clk,
	
	// control input 
	input wire					ctrl_wb_RegWrite_i,
	input wire					ctrl_wb_Mem2Reg_i,

	// input mem
	input wire[`RegBus]			mem_read_data_i,

	// input alu
	input wire[`RegBus]			alu_result_i,

	// input reg write addr
	input wire[`RegAddrBus]		write_addr_i,


	// control output 
	output reg					ctrl_wb_RegWrite_o,
	output reg					ctrl_wb_Mem2Reg_o,

	// output mem
	output reg[`RegBus]			mem_read_data_o,

	// output alu
	output reg[`RegBus]			alu_result_o,

	// output of register write addr
	output reg[`RegAddrBus]		write_addr_o
);

	always @ (posedge clk) begin
		if (rst == `Asserted) begin
			
		end
		else begin
			ctrl_wb_RegWrite_o <= ctrl_wb_RegWrite_i;
			ctrl_wb_Mem2Reg_o <= ctrl_wb_Mem2Reg_i;

			mem_read_data_o <= mem_read_data_i;
			
			alu_result_o <= alu_result_i;

			write_addr_o <= write_addr_i;
		end
	end

endmodule