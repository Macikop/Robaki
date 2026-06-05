/*
 * Designed by MP
 * * Description:
 * Testbench for ram_address_mux module.
 */

module ram_address_mux_tb;

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
    
    ram_address_mux #(
        .ADDRESS_WIDTH (),
        .INPUTS_NUMBER ()
    ) dut (
        .clk (),
        .rst_n (),
        .addresses (),
        .ram_address ()
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
