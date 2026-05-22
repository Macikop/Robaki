/*
 * Designed by MP
 * 
 * How it works:
 * Tests sequencer
 */

module sync_generator_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.3846;     // 65 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam FILE_SIZE = 38;


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    wire sync;

    /*
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /*
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /*
     * Model sync generation
     */

    logic [7:0] count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 0;
        else
            count <= count + 1;
    end

    /*
     * Dut placement
     */

    sync_generator u_sync_generator(
        .clk,
        .rst_n,

        .sync(sync)
    );
    /**
     * Tasks and functions
     */

    

    /*
     * Assertions
     */

    /*
     * Sync test
     */

    
    assert property (
        @(posedge clk)
        disable iff (!rst_n || $realtime < RST_START_TIME)
        (count == 8'd255) |=> sync
    ) else begin
        $error("Sync missing at expected cycle");
    end



    /*
     * Main test
     */

    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        repeat (512) @(posedge clk);

        $display("Test finished");

        $finish;
    end

endmodule
