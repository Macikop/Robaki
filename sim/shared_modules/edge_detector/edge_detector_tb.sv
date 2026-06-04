/*
 * Designed by MP
 * Modified for modular task formatting.
 */

module edge_detector_tb;

    timeunit 1ns;
    timeprecision 1ps;

    localparam CLK_PERIOD = 10;
    localparam RST_START_TIME  = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;

    logic clk, rst_n;
    logic din, edge_detected;

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    edge_detector #(
        .POSITIVE(1'b1)
    ) dut (
        .clk,
        .rst_n,

        .din(din),
        .edge_detected(edge_detected)
    );

    task test_constant_signals();
        $display("Starting Test 1: Constant Signals");
        
        din <= 1'b0;
        repeat(2) @(posedge clk);
        assert (!edge_detected) else $error("False edge detected on constant 0");

        din <= 1'b1;
        repeat(2) @(posedge clk);
        assert (!edge_detected) else $error("False edge detected on constant 1");
    endtask

    task test_edge_transients();
        $display("Starting Test 2: Edge Transients");
        
        din <= 1'b0;
        repeat(3) @(posedge clk);
        
        din <= 1'b1;
        
        @(posedge clk);
        assert (edge_detected == 1'b1) else $error("Failed to detect rising edge! exp: 1, rcv: %b", edge_detected);

        @(posedge clk);
        assert (edge_detected == 1'b0) else $error("Edge detector output stayed high too long!");
    endtask

    initial begin
        din <= 1'b0;

        @(negedge rst_n);
        @(posedge rst_n);

        test_constant_signals();
        test_edge_transients();

        $display("All tests completed successfully.");
        $finish;
    end

endmodule