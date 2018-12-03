`timescale 1ns / 1ps

`include "defines.v"

module sram_ctrl (
    // ctrl
    input wire rst,
    input wire                  mem_ctrl_ram,

    // ext
    input wire[`RegBus]         ext_ram_data_i,

    output reg[`RegBus]         ext_ram_data_o,
    output reg[`RamAddrBus]     ext_ram_addr,
    output reg[3:0]             ext_ram_be_n,
    output reg                  ext_ram_ce_n,
    output reg                  ext_ram_oe_n,
    output reg                  ext_ram_we_n,

    // base
    input wire[`RegBus]         base_ram_data_i,

    output reg[`RegBus]         base_ram_data_o,
    output reg[`RamAddrBus]     base_ram_addr,
    output reg[3:0]             base_ram_be_n,
    output reg                  base_ram_ce_n,
    output reg                  base_ram_oe_n,
    output reg                  base_ram_we_n,

	// rom
    input wire[`RamAddrBus]     rom_addr,
    input wire                  rom_ce_n,
    output reg[`RegBus]         rom_data_i,

    // ram
    input wire[`RegBus]         ram_data_o,
    input wire[`RamAddrBus]     ram_addr,
    input wire[3:0]             ram_be_n,
    input wire                  ram_ce_n,
    input wire                  ram_oe_n,
    input wire                  ram_we_n,
    output reg[`RegBus]         ram_data_i
);
    always @ (*) begin
        if (rst == `DeAsserted) begin
            if (mem_ctrl_ram == `Asserted) begin
                if (ram_we_n == `DeAsserted) begin
                    ext_ram_data_o <= ram_data_o;
                    ram_data_i <= `High;
                end
                else if (ram_oe_n == `DeAsserted) begin
                    ext_ram_data_o <= `High;
                    ram_data_i <= ext_ram_data_i;
                end
                else begin
                    ext_ram_data_o <= `High;
                    ram_data_i <= `High;
                end
                ext_ram_addr <= ram_addr;
                ext_ram_be_n <= ram_be_n;
                ext_ram_ce_n <= ram_ce_n;
                ext_ram_oe_n <= ram_oe_n;
                ext_ram_we_n <= ram_we_n;
    
                base_ram_ce_n <= `Asserted;
                base_ram_oe_n <= `Asserted;
                base_ram_we_n <= `Asserted;
                base_ram_data_o <= `High;
            end
            else begin
                if (ram_we_n == `DeAsserted) begin
                    base_ram_data_o <= ram_data_o;
                    ram_data_i <= `High;
                end
                else if (ram_oe_n == `DeAsserted) begin
                    base_ram_data_o <= `High;
                    ram_data_i <= base_ram_data_i;
                end
                else begin
                    base_ram_data_o <= `High;
                    ram_data_i <= `High;
                end
                base_ram_addr <= ram_addr;
                base_ram_be_n <= ram_be_n;
                base_ram_ce_n <= ram_ce_n;
                base_ram_oe_n <= ram_oe_n;
                base_ram_we_n <= ram_we_n;
    
                ext_ram_data_o <= `High;
                rom_data_i <= ext_ram_data_i;
                ext_ram_addr <= rom_addr;
                ext_ram_be_n <= 4'b0000;
                ext_ram_ce_n <= rom_ce_n;
                ext_ram_oe_n <= `DeAsserted;
                ext_ram_we_n <= `Asserted;
            end
        end
        else begin
            base_ram_data_o <= `High;
            base_ram_addr <= 20'hzzzzz;
            ram_data_i <= `High;
            base_ram_ce_n <= `Asserted;
            base_ram_oe_n <= `Asserted;
            base_ram_we_n <= `Asserted;
            
            ext_ram_data_o <= `High;
            rom_data_i <= ext_ram_data_i;
            ext_ram_addr <= rom_addr;
            ext_ram_be_n <= 4'b0000;
            ext_ram_ce_n <= rom_ce_n;
            ext_ram_oe_n <= `DeAsserted;
            ext_ram_we_n <= `Asserted;
        end
    end

endmodule