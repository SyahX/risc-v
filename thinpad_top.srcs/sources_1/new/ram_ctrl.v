`timescale 1ns / 1ps

`include "defines.v"

module ram_ctrl (
	input wire rst,
	input wire clk,

	input wire[`RegBus]		ram_write_data_i,
	input wire[`RamAddrBus]	ram_addr_i,
    input wire[3:0] 		ram_be_n_i,
    input wire 				ram_ce_n_i,
    input wire 				ram_oe_n_i,
    input wire 				ram_we_n_i,

    input wire[`RegBus]		ram_read_data_i,
    output reg[`RegBus]		ram_write_data_o,
    
    output reg[`RegBus]		ram_read_data_o,
    output reg[`RamAddrBus]	ram_addr_o,
    output reg[3:0] 		ram_be_n_o,
    output reg 				ram_ce_n_o,
    output reg 				ram_oe_n_o,
    output reg 				ram_we_n_o,

    output wire				ram_finish_o
);
	assign ram_finish_o = `DeAsserted;

	always @ (*) begin
		if (rst == `Asserted) begin
			ram_ce_n_o <= `Asserted;
			ram_oe_n_o <= `Asserted;
			ram_we_n_o <= `Asserted;

			ram_read_data_o <= `High;
		end
		else begin
			ram_addr_o <= ram_addr_i;
			ram_be_n_o <= ram_be_n_i;
			ram_ce_n_o <= ram_ce_n_i;
			ram_oe_n_o <= ram_oe_n_i;
			ram_we_n_o <= ram_we_n_i;

			if (ram_oe_n_i == `DeAsserted) begin
				ram_read_data_o <= ram_read_data_i;
			end
			else begin
				ram_read_data_o <= `High;
			end
		end
	end

	always @ (negedge clk) begin
		if (rst == `DeAsserted && ram_we_n_i == `DeAsserted) begin
			ram_write_data_o <= ram_write_data_i;
		end
		else begin
			ram_write_data_o <= `High;
		end
	end

endmodule