`timescale 1ns / 1ps

`include "defines.v"

module Test_Min_Sopc(
    
);
    reg CLOCK_50;
    reg CLOCK_10;
    reg rst;
    
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end
    initial begin
        CLOCK_10 = 1'b0;
        forever #50 CLOCK_10 = ~CLOCK_10;
    end
    
    initial begin
        rst = `Asserted;
        #195 rst= `DeAsserted;
        #3000 $stop;
    end
    
    risc_min_sopc risc_min_sopc0(
        .clk(CLOCK_50),
        .clk_11M(CLOCK_10),
        .rst(rst)
    );
    
    wire clk_10M;
    clock_new clock_new0(
        .clk_50M(CLOCK_50),
        .reset_btn(rst),
        .clk_10M(clk_10M)
        );
    
endmodule
