`timescale 1ns / 1ps

`include "defines.v"

module inst_rom(
    input wire ce,
    input wire[`InstAddrBus] addr,
    output reg[`InstBus] inst
);
    reg[`InstBus] inst_mem[0:`InstMemNum-1];
    initial $readmemh ( "/mnt/hgfs/Virtualbox/CPU/test/C11/test3/inst_rom.data", inst_mem );
    //initial $readmemh ( "/mnt/hgfs/Virtualbox/CPU/test/C4/inst_rom.data", inst_mem );
    //initial $readmemh ( "D:/Virtualbox/CPU/test/C11/test1/inst_rom.data", inst_mem );
    always @ (*) begin
        if (ce == `ChipDisable) begin
            inst <= `ZeroWord;
        end else begin
            inst <= inst_mem[addr[`InstMemNumLog2+1:2]];
        end
    end
endmodule
