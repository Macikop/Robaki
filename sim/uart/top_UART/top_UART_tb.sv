`timescale 1ns / 1ps

module tb_uart_top;

    // Parameters matching standard design
    localparam int CLK_FREQ = 100_000_000;
    localparam int BAUD_RATE = 115200;

    logic       clk;
    logic       rst_n;
    logic       uart_rx;
    logic       uart_tx;
    logic       wr_en;
    logic [7:0] wr_data;
    logic       rd_en;
    logic [7:0] rd_data;
    logic       tx_full;
    logic       rx_empty;

    // Instantiate System Top Module
    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(8)
    ) uut (.*);

    // External loopback connection
    // What goes out of TX comes right back into RX!
    assign uart_rx = uart_tx;

    // Clock definition
    always #5 clk = ~clk;

    // Helper Tasks for cleaner stimulation flow
    task automatic tx_push_byte(input logic [7:0] data);
        begin
            while (tx_full) @(posedge clk); // Backpressure wait if full
            wr_data = data;
            wr_en   = 1'b1;
            @(posedge clk);
            wr_en   = 1'b0;
        end
    endtask

    task automatic rx_pop_byte(output logic [7:0] data);
        begin
            while (rx_empty) @(posedge clk); // Wait until data shows up
            rd_en = 1'b1;
            @(posedge clk);
            data = rd_data;
            rd_en = 1'b0;
        end
    endtask

    // Monitoring Variable
    logic [7:0] received_byte;

    initial begin
        // Setup initial wires
        clk     = 1'b0;
        rst_n   = 1'b0;
        wr_en   = 1'b0;
        rd_en   = 1'b0;
        wr_data = 8'h0;
        
        #50;
        rst_n   = 1'b1; // Wake up logic
        @(posedge clk);
        
        $display("[SYSTEM TEST] Starting System-Level Loopback Test...");

        // Send Byte 1: 0x5A (Binary: 01011010)
        $display("[SYSTEM TEST] Sending 0x5A over UART loopback link...");
        tx_push_byte(8'h5A);

        // Wait for loopback to completely finish frame processing
        // At 115200 baud, 1 frame (10 bits) takes ~86.8 microseconds
        rx_pop_byte(received_byte);
        $display("[SYSTEM TEST] Received Byte back: 0x%h", received_byte);
        assert(received_byte == 8'h5A) else $error("Loopback payload corrupted!");

        #2000;

        // Send Byte 2: 0x38 (Testing an alternative sequence)
        $display("[SYSTEM TEST] Sending 0x38 over UART loopback link...");
        tx_push_byte(8'h38);

        rx_pop_byte(received_byte);
        $display("[SYSTEM TEST] Received Byte back: 0x%h", received_byte);
        assert(received_byte == 8'h38) else $error("Loopback payload corrupted!");

        #5000;
        $display("[SYSTEM TEST] All loopback assertions passed cleanly.");
        $finish;
    end

endmodule