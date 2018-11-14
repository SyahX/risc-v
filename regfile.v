`timescale 1ns / 1ps

`include "defines.v"

module regfile (
	input wire clk,
	input wire rst,
	
	// read register 1
	input wire[`RegAddrBus]	read_addr_1,
	output reg[`RegBus]		read_data_1,

	// read register 2
	input wire[`RegAddrBus]	read_addr_2,
	output reg[`RegBus]		read_data_2,

	// write register
	input wire 				write_ce,
	input wire[`RegAddrBus]	write_addr,
	input wire[`Regbus]		write_data
);

reg[`RegBus] regs[0 : `RegNum - 1]

	// write register
	always @ (*) 
	begin
		if (rst == `DeAsserted)
		begin
			if ((write_ce == `Assert) && (write_addr != `RegNumLog2'h0))
			begin
				regs[write_addr] <= write_data;
			end
		end
	end

	// read register 1
	always @ (*)
	begin
		if (rst == `DeAsserted)
		begin
			read_data_1 <= `ZeroWord;
		end
		else if (read_addr_1 == `RegNumLog2'h0)
		begin
			read_data_1 <= `ZeroWord;
		end
		else if ((read_addr_1 == write_addr) && (write_ce == `Assert))
		begin
			read_data_1 <= write_data;
		end
		else
		begin
			read_data_1 <= regs[read_addr_1];
		end
	end

	// read register 2
	always @ (*)
	begin
		if (rst == `DeAsserted)
		begin
			read_data_2 <= `ZeroWord;
		end
		else if (read_addr_2 == `RegNumLog2'h0)
		begin
			read_data_2 <= `ZeroWord;
		end
		else if ((read_addr_2 == write_addr) && (write_ce == `Assert))
		begin
			read_data_2 <= write_data;
		end
		else
		begin
			read_data_2 <= regs[read_addr_2];
		end
	end

endmodule