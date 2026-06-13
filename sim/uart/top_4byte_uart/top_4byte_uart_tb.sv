`timescale 1ns / 1ps

module top_4byte_uart_tb();
    
    logic clk;
    logic rst_n;
    logic start;
    logic [31:0] data_transmit;
    logic rx;

    logic done;
    logic [31:0] data_received;
    logic tx;

    top_4byte_uart u_top_4byte_uart(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .data_transmit(data_transmit),
        .rx(rx),
        .done(done),
        .data_received(data_received),
        .tx(tx)
    );

    //connect receiver to transmitter for simulation purposes
    assign rx = tx;

    //generate clock
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    initial begin
        rst_n = 1'b0;
        start = 1'b0;
        data_transmit = 32'h0;

        //RESET
        repeat(10) @(posedge clk);
        #1;
        rst_n = 1'b1;
        repeat(5) @(posedge clk);
        
        $display("TB -- Starting top level 4byte UART loopback transmission test");
        $display("TB -- Test 1: Staging data 32'hAABBCCDD into loopback");
        @(posedge clk);
        #1;
        data_transmit = 32'hAABBCCDD;
        start = 1'b1;       //trigger transmitter
        $display("TB -- Transmission initiated");
        repeat(2) @(negedge clk);
        start = 1'b0;

        fork : timeout_guard
            begin
                @(posedge clk);
                #1;
                $display("TB -- Success! 'done' flag captured high.");
                disable timeout_guard;
            end
            begin
                #1_000_000;
                $error("TB -- ERROR: simulation timed out! 'done' flag never asserted");
                $finish;
            end
        join

        #1_000_000;
        if(data_received === data_transmit) begin
            $display("[SUCCESS] -- Packet matched perfectly");
            $display("      Sent:       32'h%h", data_transmit);
            $display("      Received:   32'h%h", data_received);
        end else begin
            $error("[FAILURE] -- Mismatch detected in data transmission");
            $display("      Sent:       32'h%h", data_transmit);
            $display("      Received:   32'h%h", data_received);
        end

        repeat(100) @(posedge clk);
        $display("TB -- Top level verification complete --");
        
        $finish;
    end
    
endmodule