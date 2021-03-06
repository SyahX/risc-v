`timescale 1ns / 1ps

`include "defines.v"

module if_id(
	input wire clk,
	input wire rst,

	input wire 					ctrl_if_flush,
	input wire					if_id_hold,
	input wire[`InstAddrBus]	if_pc,
	input wire[`InstBus]		if_inst,
	
	output reg[`InstAddrBus]	id_pc,
	output reg[`InstBus]		id_inst
);

	always @ (posedge clk) begin
		if (rst == `Asserted) begin
			id_pc <= `ZeroWord;
			id_inst <= `ZeroWord;
		end 
		else if (if_id_hold == `DeAsserted) begin
		    if (ctrl_if_flush == `Asserted) begin
		        id_pc <= `ZeroWord;
		        id_inst <= `ZeroWord;
		    end
		    else begin
		        id_pc <= if_pc;
			    id_inst <= if_inst;
			end
		end 
	end

endmodule