/*
 * Designed by MP
 * 
 * Description:
 * Testbench for delay module.
 */

module delay_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam CLK_DEL = 2;
    localparam WIDTH = 32;


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic [WIDTH-1:0] din;

    wire [WIDTH-1:0] dout;

    logic [WIDTH-1:0] reference [$];
    

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

    delay #(
        .WIDTH(WIDTH),
        .CLK_DEL(CLK_DEL)
    ) dut (
        .clk,
        .rst_n,

        .din(din),
        .dout(dout)
    );

    /**
     * Tasks and functions
     */

    task automatic check_delay(input int cycles);

    

    for (int i = 0; i < cycles + CLK_DEL + 5; i++) begin

        reference = {};
        din = $urandom;

        @(posedge clk);

        reference.push_front(din);

        if (reference.size() > CLK_DEL) begin
            assert (dout == reference[CLK_DEL])
            else begin
                $error("ASSERTION FAILED @%0t: dout=%0h expected=%0h",
                $time, dout, reference[CLK_DEL]);
                $fatal;
            end
        end
    end

    $display("Delay check passed for %0d cycles", cycles);

endtask


    /**
     * Assertions
     */


    /**
     * Main test
     */

    initial begin
        check_delay(100);

        $finish;
    end

endmodule
