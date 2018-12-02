`timescale 1ns / 1ps

`include "defines.v"

module data_mux(
	// reg1 
	input wire[`RegBus]	id_reg1_data_i,
	input wire[`RegBus]	mem_reg1_data_i,
	input wire[`RegBus]	wb_reg1_data_i,

	// reg2
	input wire[`RegBus]	id_reg2_data_i,
	input wire[`RegBus]	mem_reg2_data_i,
	input wire[`RegBus]	wb_reg2_data_i,

	// mux
	input wire[1:0]		alu_mux1_i,
	input wire[1:0]		alu_mux2_i,

	// output reg
	output reg[`RegBus]	reg1_data_o,
	output reg[`RegBus]	reg2_data_o
);

	always @ (*) begin
		if (alu_mux1_i == 2'b00) begin
			reg1_data_o <= id_reg1_data_i;
		end
		else if (alu_mux1_i == 2'b01) begin
			reg1_data_o <= mem_reg1_data_i;
		end
		else if (alu_mux1_i == 2'b10) begin
			reg1_data_o <= wb_reg1_data_i;
		end
		else begin
		    reg1_data_o <= `ZeroWord;
		end
	end

	always @ (*) begin
		if (alu_mux2_i == 2'b00) begin
			reg2_data_o <= id_reg2_data_i;
		end
		else if (alu_mux2_i == 2'b01) begin
			reg2_data_o <= mem_reg2_data_i;
		end
		else if (alu_mux2_i == 2'b10) begin
			reg2_data_o <= wb_reg2_data_i;
		end
		else begin
            reg2_data_o <= `ZeroWord;
        end
	end

endmodule