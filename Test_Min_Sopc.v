`timescale 1ns / 1ps

module Test_Min_Sopc(
    
);
    reg CLOCK_50;
    reg rst;
    
    initial begin
        CLOCK_50 = 1'b0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end
    
    initial begin
        rst = `RstEnable;
        #195 rst= `RstDisable;
        #3000 $stop;
    end
    
    risc_min_sopc risc_min_sopc0(
        .clk(CLOCK_50),
        .rst(rst)
    );
    
endmodule
