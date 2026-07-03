/*
 * Designed by MP
 * * Description:
 * Testbench for sr_flip_flop module with styled SystemVerilog Assertions.
 */

module sr_flip_flop_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;
    localparam string PRIORITY = "SET"; // Options: "SET", "RESET"

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    logic s;
    logic r;
    logic q;


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
    
    sr_flip_flop #(
        .PRIORITY (PRIORITY)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .s     (s),
        .r     (r),
        .q     (q)
    );


    /**
     * Tasks and functions
     */

    task automatic init_inputs();
        s = 1'b0;
        r = 1'b0;
    endtask

    task automatic drive_stimulus(input logic local_s, input logic local_r);
        @(negedge clk);
        s = local_s;
        r = local_r;
    endtask


    /**
     * Assertions
     */

    // 1. Reset Assertion
    assert property (
        @(posedge clk)
        !rst_n |-> (q == 1'b0)
    ) else begin
        $error("Reset: active low reset failed");
    end

    // 2. Set Assertion
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (s && !r) |=> (q == 1'b1)
    ) else begin
        $error("SET: operation failed");
    end

    // 3. Reset/Clear Assertion
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (!s && r) |=> (q == 1'b0)
    ) else begin
        $error("RESET: operation failed");
    end

    // 4. Hold Assertion
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (!s && !r) |=> (q == $past(q))
    ) else begin
        $error("HOLD: operation failed");
    end

    // 5. Priority Condition Assertion
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (s && r) |=> (PRIORITY == "SET" ? (q == 1'b1) : (q == 1'b0))
    ) else begin
        $error("PRIORITY: dual high input resolution failed");
    end


    /**
     * Main test
     */

    initial begin
        init_inputs();

        @(negedge rst_n);
        @(posedge rst_n);
        

        /* SET */
        drive_stimulus(.local_s(1'b1), .local_r(1'b0));
        repeat (2) @(posedge clk); 

        /* HOLD */
        drive_stimulus(.local_s(1'b0), .local_r(1'b0));
        repeat (2) @(posedge clk);

        /* RESET */
        drive_stimulus(.local_s(1'b0), .local_r(1'b1));
        repeat (2) @(posedge clk);

        /* HOLD */
        drive_stimulus(.local_s(1'b0), .local_r(1'b0));
        repeat (2) @(posedge clk);

        /* BOTH HIGH */
        drive_stimulus(.local_s(1'b1), .local_r(1'b1));
        repeat (2) @(posedge clk);

        // Clear and finish
        drive_stimulus(.local_s(1'b0), .local_r(1'b0));
        repeat (2) @(posedge clk);
        
        $finish;
    end

endmodule