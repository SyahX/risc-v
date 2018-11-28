`timescale 1ns / 1ps

`include "defines.v"

module pc_reg (
	input wire		clk,
	input wire		rst,

	input wire 					pc_hold_i,
	input wire 					ctrl_pc_src_i,
	input wire[`InstAddrBus]	pc_i,
	input wire[`InstAddrBus]	branch_pc_i,

	output reg[`InstAddrBus]	pc_o,
	
	output reg                  rom_ce_o
);
    always @ (posedge clk) begin
        if (rst == `Asserted) begin
            rom_ce_o <= `DeAsserted;
        end
        else begin
            rom_ce_o <= `Asserted;
        end
    end

	always @ (posedge clk) begin
		if (pc_hold_i == `DeAsserted) begin
			if (rom_ce_o == `DeAsserted) begin
				pc_o <= 32'h00000000;
			end
			else begin
				if (ctrl_pc_src_i == `Asserted) begin
					pc_o <= branch_pc_i;
				end
				else begin
					pc_o <= pc_i;
				end
			end
		end
	end

endmodule


