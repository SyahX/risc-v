`timescale 1ns / 1ps

`include "defines.v"

module risc_min_sopc(
	input wire clk,
    input wire clk_11M,
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

    wire[7:0]   uart_data;
    wire uart_data_ready;
    wire uart_tbre;
    wire uart_tsre;
    wire uart_rdn;
    wire uart_wrn;

	risc risc0(
		.clk(clk),
        .clk_11M(clk_11M),
        .rst(rst),
        
        .ext_ram_data(inst),
        
        .ext_ram_addr(inst_addr),
        //.ext_ram_be_n(ext_ram_be_n),
        .ext_ram_ce_n(rom_ce),
        //.ext_ram_oe_n(ext_ram_oe_n),
        //.ext_ram_we_n(ext_ram_we_n),

        // base
        .base_ram_data(ram_data),

        .base_ram_addr(ram_addr),
        .base_ram_be_n(ram_be_n),
        .base_ram_ce_n(ram_ce_n),
        .base_ram_oe_n(ram_oe_n),
        .base_ram_we_n(ram_we_n),

        // uart
        .uart_data(uart_data),
        .uart_data_ready(uart_data_ready),
        .uart_tbre(uart_tbre),
        .uart_tsre(uart_tsre),

        .uart_rdn(uart_rdn),
        .uart_wrn(uart_wrn)
	);

	inst_rom inst_rom0(
        .addr(inst_addr),
        .inst(inst),
        .ce(rom_ce)
    );

    sram sram0(
        .ram_data_i(ram_data),
        .ram_data_o(ram_data),

        .ram_addr(ram_addr),
        .ram_be_n(ram_be_n),
        .ram_ce_n(ram_ce_n),
        .ram_oe_n(ram_oe_n),
        .ram_we_n(ram_we_n)
    );

    uart uart0(
        .uart_data_i(uart_data),
        .uart_data_o(uart_data),

        .uart_rdn(uart_rdn),
        .uart_wrn(uart_wrn),
        
        .uart_data_ready(uart_data_ready),
        .uart_tbre(uart_tbre),
        .uart_tsre(uart_tsre)
    );

endmodule