timescale 1ns / 1ps

`include "defines.v"

module detection(
	input wire[`InstBus]		inst_i,
	input wire 					ex_ctrl_mem_read_i,
	input wire 					ex_ctrl_wb_Mem2Reg_i,
	input wire[`RegAddrBus]		ex_write_addr_i,

	output reg 					pc_hold_o,
	output reg 					if_id_hold_o,
	output reg 					ctrl_mux_o
);
	wire[6:0] op = inst_i[6:0];
	wire[4:0] rs1 = inst_i[19:15];
	wire[4:0] rs2 = inst_i[24:20];

	always @ (*) begin
        if (ex_ctrl_mem_read_i == `Asserted &&
        	ex_ctrl_wb_Mem2Reg_i == `Asserted &&
        	(((op == `Btype || op == `Stype || op == `Rtype) &&
        	  rs2 == ex_write_addr_i) || 
        	 rs1 == ex_write_addr_i)) begin
        	pc_hold_o <= `Asserted;
        	if_id_hold_o <= `Asserted;
        	ctrl_mux_o <= `Asserted;	 	
        end
        else begin
        	pc_hold_o <= `DeAsserted;
        	if_id_hold_o <= `DeAsserted;
        	ctrl_mux_o <= `DeAsserted;	 
        end
    end

endmodule