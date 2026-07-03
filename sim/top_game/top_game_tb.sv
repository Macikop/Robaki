/*
 * Designed by MP
 * 
 * Description:
 * Testbench for top_game module.
 */

module top_game_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD_CORE = 10;            // 100 MHz
    localparam CLK_PERIOD_VGA = 15.3846;        // 65 MHz

    localparam RST_START_TIME  = 1.25*CLK_PERIOD_VGA;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD_VGA;

    /**
     * Local variables and signals
     */

    logic clk_core, clk_vga;
    logic rst_n;
    

    /**
     * Clock generation
     */

    initial begin
        clk_core = 1'b0;
        forever #(CLK_PERIOD_CORE/2) clk_core = ~clk_core;
    end

    initial begin
        clk_vga = 1'b0;
        forever #(CLK_PERIOD_VGA/2) clk_vga = ~clk_vga;
    end


    /**
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end


    /*
     * Supporting modules
     */


    /**
     * Dut placement
     */
    
    top_game dut (
        .clk_core  (clk_core),
        .clk_media (clk_vga),
        .rst_n     (rst_n),
        .up        (),
        .down      (),
        .right     (),
        .left      (),
        .space     (),
        .r         (),
        .g         (),
        .b         (),
        .vs        (),
        .hs        ()
    );


    /**
     * Tasks and functions
     */


    /**
     * Assertions
     */


    /**
     * Main test
     */

    initial begin

        @(negedge rst_n);
        @(posedge rst_n);

        repeat (1000000) @(posedge clk_core);

        $finish;
    end

endmodule
