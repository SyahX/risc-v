`timescale 1ns / 1ps

`include "defines.v"

module sram (
	input wire[`RamAddrBus] ram_addr,
    input wire[3:0] 		ram_be_n,
    input wire 				ram_ce_n,
    input wire 				ram_oe_n,
    input wire 				ram_we_n,

    output reg[`RegBus] 	ram_data
);
	
	reg[7:0]  ram3[0:1048575];
	reg[7:0]  ram2[0:1048575];
	reg[7:0]  ram1[0:1048575];
	reg[7:0]  ram0[0:1048575];

	always @ (*) begin
		if (ram_ce_n == `DeAsserted && ram_we_n == `DeAsserted) begin
			if (ram_be_n[3] == 1'b0) begin
		    	ram3[ram_addr] <= ram_data[31:24];
		    end
			if (ram_be_n[2] == 1'b0) begin
		    	ram2[ram_addr] <= ram_data[23:16];
		    end
		    if (ram_be_n[1] == 1'b0) begin
		    	ram1[ram_addr] <= ram_data[15:8];
		    end
			if (ram_be_n[0] == 1'b0) begin
		    	ram0[ram_addr] <= ram_data[7:0];
		    end			   	    
		end
	end
	
	always @ (*) begin
		if (ram_ce_n == `DeAsserted && 
			ram_we_n == `Asserted &&
			ram_oe_n == `DeAsserted) begin
		    ram_data <= {ram3[ram_addr],
		                 ram2[ram_addr],
		                 ram1[ram_addr],
		                 ram0[ram_addr]};
		end else begin
	        ram_data <= 32'bz;
		end
	end		

endmodule
