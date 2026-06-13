module transmitter_4byte(
        input logic clk,
        input logic rst_n,
        input logic start,
        input logic[31:0] data32,
        input logic tx_full,
        output logic wr_uart,
        output logic[7:0] w_data,
        output logic empty
    );

    timeunit 1ns;
    timeprecision 1ps;

    logic [31:0] data_reg;
    logic[2:0] byte_ctr;    //tracks 0 to 4 bytes sent

    assign empty = (byte_ctr == 3'd0);

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wr_uart <= '0;
            w_data <= '0;
            data_reg <= '0;
            byte_ctr <= 3'd0;
        end else begin
            wr_uart <= 1'b0;     //default pulse low

            if(byte_ctr == 3'd0) begin
                if(start) begin
                    data_reg <= data32;
                    byte_ctr <= 3'd4;   //prepare to send 4 bytes
                end
            end else begin
                if(!tx_full && !wr_uart) begin
                    wr_uart <= 1'b1;
                    w_data <= data_reg[7:0];
                    data_reg <= data_reg >> 8;
                    byte_ctr <= byte_ctr - 1'b1;
                end
            end
        end
    end


endmodule