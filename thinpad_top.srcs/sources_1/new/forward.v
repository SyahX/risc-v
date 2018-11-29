`timescale 1ns / 1ps

`include "defines.v"

module forward (
	// input reg addr in id
	input wire[`RegAddrBus]		id_reg1_addr_i,
	input wire[`RegAddrBus]		id_reg2_addr_i,

	// ctrl & addr from mem
	input wire					mem_ctrl_wb_RegWrite_i,
	input wire[`RegAddrBus]		mem_write_addr_i,

	// ctrl & addr from wb
	input wire 					wb_ctrl_wb_RegWrite_i,
	input wire[`RegAddrBus]		wb_write_addr_i,

	// output for first
	output reg[1:0]				alu_mux1_o,
	output reg[1:0]				alu_mux2_o	
);
	always @ (*) begin
		if (mem_write_addr_i != 5'b00000 &&
		    mem_write_addr_i == id_reg1_addr_i &&
			mem_ctrl_wb_RegWrite_i == `Asserted) begin
			alu_mux1_o <= 2'b01;
		end
		else if (wb_write_addr_i != 5'b00000 &&
		         wb_write_addr_i == id_reg1_addr_i &&
				 wb_ctrl_wb_RegWrite_i == `Asserted) begin
			alu_mux1_o <= 2'b10;
		end
		else begin
			alu_mux1_o <= 2'b00;
		end
	end

	always @ (*) begin
		if (mem_write_addr_i != 5'b00000 &&
		    mem_write_addr_i == id_reg2_addr_i &&
			mem_ctrl_wb_RegWrite_i == `Asserted) begin
			alu_mux2_o <= 2'b01;
		end
		else if (wb_write_addr_i != 5'b00000 &&
		         wb_write_addr_i == id_reg2_addr_i &&
				 wb_ctrl_wb_RegWrite_i == `Asserted) begin
			alu_mux2_o <= 2'b10;
		end
		else begin
			alu_mux2_o <= 2'b00;
		end
	end

endmodule