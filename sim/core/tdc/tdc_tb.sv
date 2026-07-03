/*
 * Designed by MP
 * 
 * Description:
 * Testbench for tdc module.
 */

module tdc_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam SYNC_CLK_CYCLES = 10;
    
    localparam MAX_TIME = 10;
    

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic sync;
    logic enable;
    logic pulse;
    logic [$clog2(MAX_TIME + 1)-1:0] value;
    logic done;
    

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

    /*
     * Sync generation
     */

    initial begin
        forever begin
            sync = 1'b1;
            @(posedge clk);
            sync = 1'b0;
            repeat (SYNC_CLK_CYCLES-1) @(posedge clk);
        end       
    end

    /**
     * Dut placement
     */
    
    tdc #(
        .MAX_TIME(MAX_TIME)
    ) dut (
        .clk,
        .rst_n,

        .sync(sync),
        .enable(enable),
        .pulse(pulse),
        .value(value),
        .done(done)
    );


    /**
     * Tasks and functions
     */

    task automatic value_test (input int test_value);
        enable <= 1'b0;
        pulse  <= 1'b0;
        @(posedge clk);
        
        @(posedge sync);
        enable <= 1'b1;
        pulse  <= 1'b1;

        repeat (test_value) @(posedge sync);
        pulse <= 1'b0;

        @(posedge clk);
        @(negedge clk);

        assert (done && (value == test_value)) begin
            $display("PASSED: value_test passed for value = %0d", test_value);
        end else begin
            $error("FAILED: Expected value = %d, done = 1. Got value = %d, done = %d", test_value, value, done);
        end
    endtask
    

    task automatic saturation_test ();
        enable <= 1'b0;
        pulse  <= 1'b0;
        @(posedge clk);
        
        @(posedge sync);
        enable <= 1'b1;
        pulse  <= 1'b1;

        repeat (MAX_TIME+2) @(posedge sync);
        pulse <= 1'b0;

        @(posedge clk);
        @(negedge clk);

        assert (done && (value == MAX_TIME)) begin
            $display("PASSED: saturation_test for MAX_TIME = %d, passed for time = %0d, got value = %d", MAX_TIME, MAX_TIME + 2, value);
        end else begin
            $error("FAILED: Expected value = %d, done = 1. Got value = %d, done = %d", MAX_TIME, value, done);
        end
    endtask

    task automatic enable_test ();
        enable <= 1'b0;
        pulse  <= 1'b0;
        @(posedge clk);
        
        @(posedge sync);
        enable <= 1'b1;
        pulse  <= 1'b1;

        repeat (2) @(posedge sync);
        enable <= 1'b0;

        @(posedge clk);
        @(negedge clk);

        assert (~done && (value == '0)) begin
            $display("PASSED: Enable test, value = %d", value);
        end else begin
            $error("FAILED: Expected value = 0, done = 1. Got value = %d, done = %d", value, done);
        end
    endtask


    /**
     * Assertions
     */


    /**
     * Main test
     */

    initial begin

        @(negedge rst_n);
        @(posedge rst_n);

        value_test(3);
        saturation_test();
        enable_test();

        repeat (10) @(posedge clk);

        $finish;
    end

endmodule
