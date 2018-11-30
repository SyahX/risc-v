`timescale 1ns / 1ps

`include "defines.v"

module risc_min_sopc(
	input wire clk,
    input wire rst
);
	wire[`InstAddrBus] inst_addr;
	wire[`InstBus] inst;
	wire rom_ce;

    wire[`RamAddrBus] ram_addr;
    wire[3:0]         ram_be_n;
    wire              ram_ce_n;
    wire              ram_oe_n;
    wire              ram_we_n;
    wire[`RegBus]     ram_data;

	risc risc0(
		.clk(clk),
        .rst(rst),
        
        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce_o(rom_ce),

        .ram_data(ram_data),

        .ram_addr(ram_addr),
        .ram_be_n(ram_be_n),
        .ram_ce_n(ram_ce_n),
        .ram_oe_n(ram_oe_n),
        .ram_we_n(ram_we_n)
	);

	inst_rom inst_rom0(
        .addr(inst_addr),
        .inst(inst),
        .ce(rom_ce)
    );

    sram sram0(
        .ram_data(ram_data),

        .ram_addr(ram_addr),
        .ram_be_n(ram_be_n),
        .ram_ce_n(ram_ce_n),
        .ram_oe_n(ram_oe_n),
        .ram_we_n(ram_we_n)
    );

endmodule