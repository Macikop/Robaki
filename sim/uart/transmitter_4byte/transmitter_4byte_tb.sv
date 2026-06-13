`timescale 1ns/1ps

module transmitter_4byte_tb();

    logic clk;
    logic rst_n;
    logic start;
    logic [31:0] data32;
    logic tx_full;

    logic wr_uart;
    logic [7:0] w_data;
    logic empty;

    transmitter_4byte u_transmitter_4byte(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data32(data32),
        .tx_full(tx_full),
        .wr_uart(wr_uart),
        .w_data(w_data),
        .empty(empty)
    );

    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        data32 = 32'h0;
        tx_full = 1'b0;

        repeat(4) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        $display("TB -- starting UART 4-Byte transmitter test");

        $display("TB -- Test 1: Sending 32'hDDCCBBAA...");
        data32 = 32'hDDCCBBAA;
        start = 1'b1;
        @(posedge clk); 
        #1;
        start = 1'b0;

        while(!empty) begin
            @(posedge clk);
        end
        #5;

        $display("TB -- Test 1 FINISHED -- transmitter returned to empty state");
        #20;

        $display("TB -- Test 2: Sending all-zeros 32'h00000...");
        data32 = 32'h00000000;
        start = 1'b1;
        @(posedge clk); 
        #1;
        start = 1'b0;

        while(!empty) begin
            @(posedge clk);
        end
        #5;

        $display("TB -- Test 2 FINISHED");
        #20;

        $display("TB -- Test 3: Simulating UART full condition midway...");
        data32 = 32'h44332211;
        start = 1'b1;
        @(posedge clk); 
        #1;
        start = 1'b0;

        @(posedge wr_uart);
        $display("TB -- First byte written (8'h%h), letting it run...", w_data);

        @(posedge wr_uart);
        $display("TB -- Second byte written (8'h%h)", w_data);

        #1;
        tx_full = 1'b1;
        $display("TB -- Downstream UART full! Asserting tx_full");

        repeat(5) @(posedge clk);
        #1;
        $display("TB -- Downstream UART clearing up. De-asserting tx_full");

        tx_full = 1'b0;

        while(!empty) begin
            @(posedge clk);
        end

        $display("TB -- Test 3 Finished");

        #50;
        $display("TB -- All test completed");
        $finish;
    end

    always @(posedge clk) begin
        if(wr_uart) begin
            $display("MONITOR time: %0t ps | captured UART write! Byte value: 8'h%h", $time, w_data);
        end
    end
endmodule