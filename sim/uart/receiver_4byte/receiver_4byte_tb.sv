`timescale 1ns/1ps

module receiver_4byte_tb();

    logic clk;
    logic rst_n;
    logic rx_empty;
    logic rd_uart;
    logic [7:0] r_data;

    logic full;
    logic [31:0] data32;


    receiver_4byte u_receiver_4byte(
        .clk(clk),
        .rst_n(rst_n),
        .rx_empty(rx_empty),
        .rd_uart(rd_uart),
        .r_data(r_data),
        .full(full),
        .data32(data32)
    );

    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    initial begin
        rst_n = 1'b0;
        rx_empty = 1'b1;
        rd_uart = 1'b0;
        r_data = 8'h00;

        repeat(5) @(posedge clk);
        #1;
        rst_n = 1'b1;
        repeat(2) @(posedge clk);

        $display("TB -- starting UART 4-Byte recever test");

        $display("TB -- Test 1: simulating arrival of 4 bytes...");
        send_uart_byte(8'h11);
        send_uart_byte(8'h22);
        send_uart_byte(8'h33);
        send_uart_byte(8'h44);

        if(full) begin
            $display("TB -- Success. full signal asserted");
            $display("TB -- received 32bit data: 32'h%h, expected: 32'h44332211", data32);
        end else begin
            $display("TB ERROR: full signal failed to assert after 4 bytes");
        end

        repeat(5) @(posedge clk);

        $display("TB -- Test 2: Sending all zeros");

        send_uart_byte(8'h00);
        if(!full) begin
            $display("TB -- 'full' dropped back low upon reading a new byte");
        end
        send_uart_byte(8'h00);
        send_uart_byte(8'h00);
        send_uart_byte(8'h00);

        $display("TB -- Received 32-bit data: 32'h%h, expected: 32'h00000000", data32);
        repeat(10) @(posedge clk);
        $display("TB -- All receiver tests completed");

        $finish;
    end

    task automatic send_uart_byte(input logic [7:0] byte_to_send);
        begin
            @(posedge clk);
            #1;
            rx_empty = 1'b0;
            r_data = byte_to_send;
            rd_uart = 1'b1;

            @(posedge clk);
            #1;
            rx_empty = 1'b1;
            rd_uart = 1'b0;
            r_data = 8'h00;
        end
    endtask
endmodule