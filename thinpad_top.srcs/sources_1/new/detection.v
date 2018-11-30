`timescale 1ns / 1ps

`include "defines.v"

module detection(
	input wire[`InstBus]		inst_i,
	input wire 					ex_ctrl_mem_read_i,
	input wire 					ex_ctrl_wb_Mem2Reg_i,
	input wire                  ex_ctrl_wb_RegWrite_i,
	input wire[`RegAddrBus]		ex_write_addr_i,

    input wire                  mem_ctrl_mem_read_i,
    input wire                  mem_ctrl_wb_Mem2Reg_i,
    input wire[`RegAddrBus]     mem_write_addr_i,

	output reg 					ctrl_detection_o
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
        	ctrl_detection_o <= `Asserted;	 	
        end
        else if (op == `Btype &&
                 mem_ctrl_mem_read_i == `Asserted &&
                 mem_ctrl_wb_Mem2Reg_i == `Asserted &&
                 (rs1 == mem_write_addr_i || rs2 == mem_write_addr_i)) begin
            ctrl_detection_o <= `Asserted;
        end 
        else if (op == `Btype &&
                 ex_ctrl_wb_RegWrite_i == `Asserted &&
                 (rs1 == ex_write_addr_i || rs2 == ex_write_addr_i)) begin
            ctrl_detection_o <= `Asserted;
        end 
        else begin
        	ctrl_detection_o <= `DeAsserted;	 
        end
    end

endmodule