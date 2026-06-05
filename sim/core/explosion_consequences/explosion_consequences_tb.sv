/*
 * Designed by MP
 * * Description:
 * Testbench for explosion_consequences module.
 */

module explosion_consequences_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    

    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end


    /**
     * Dut placement
     */
    
    explosion_consequences #(
        .TERRAIN_WIDTH (),
        .TERRAIN_HEIGHT ()
    ) dut (
        .clk (),
        .rst_n (),
        .worm_pos_x (),
        .worm_pos_y (),
        .explosion_pos_x (),
        .explosion_pos_y (),
        .explosion_r (),
        .start (),
        .velocity_x (),
        .velocity_y (),
        .damage (),
        .done ()
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

        $finish;
    end

endmodule
