module transmitter_4byte(
        input logic clk,
        input logic rst_n,
        input logic[31:0] data32,
        input logic tx_full,
        output logic wr_uart,
        output logic[7:0] w_data,
        output logic empty
    );

    timeunit 1ns;
    timeprecision 1ps;

    logic [31:0] data;
    logic emptied;
    assign empty = emptied;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wr_uart <= '0;
            w_data <= '0;
            data <= data32;
        end else begin
            if(!tx_full && !emptied) begin
                wr_uart <= 1'b1;
                w_data <= data32[7:0];
                data <= data >> 8;
            end
        end
    end

    always_comb begin
        emptied = '0;
        if(data == 32'b0) begin
            emptied = 1'b1;
        end
    end

endmodule