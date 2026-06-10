`timescale 1ns / 1ps

module uart_FIFO_tb;

    localparam int DEPTH = 4; // Small depth makes boundary testing quick
    
    logic                    clk;
    logic                    rst_n;
    logic                    wr_en;
    logic [7:0]              wr_data;
    logic                    rd_en;
    logic [7:0]              rd_data;
    logic                    full;
    logic                    empty;

    uart_FIFO #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(DEPTH)
    ) u_uart_FIFO (.*); // Uses explicit wildcard connection for brevity

    // 100 MHz Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 8'h0;
        #20;
        rst_n = 1;
        @(posedge clk);

        // --- Test Case 1: Verification of Initial State ---
        assert(empty == 1'b1 && full == 1'b0) else $error("Initial flags incorrect!");

        // --- Test Case 2: Fill Up FIFO ---
        $display("Writing data into FIFO...");
        for (int i = 1; i <= DEPTH; i++) begin
            wr_data = 8'hA0 + i; // 0xA1, 0xA2...
            wr_en = 1'b1;
            @(posedge clk);
        end
        wr_en = 1'b0;
        #1; // Minor step to let flags settle
        assert(full == 1'b1) else $error("FIFO should be full!");

        // --- Test Case 3: Overfill Guard Check ---
        wr_data = 8'hFF;
        wr_en = 1'b1;
        @(posedge clk);
        wr_en = 1'b0;

        // --- Test Case 4: Drain and Verify Content ---
        $display("Reading data from FIFO...");
        
        for (int i = 1; i <= DEPTH; i++) begin
            
            #1
            $display("Read Loop Index %0d: Stored Data = %h", i, rd_data);
            assert(rd_data == (8'hA0 + i)) else $error("Data mismatch! Expected %h, Got %h", (8'hA0 + i), rd_data);

            rd_en = 1'b1;
            @(posedge clk);
            rd_en = 1'b0;
        end
        
        #1;
        assert(empty == 1'b1) else $error("FIFO should be empty!");

        $display("FIFO unit testbench completed successfully.");
        $finish;
    end

endmodule