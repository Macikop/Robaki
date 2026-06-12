module receiver_4byte(
    input logic clk,
    input logic rst_n,
    input logic rx_empty,
    input logic rd_uart,
    input logic[7:0] r_data,
    output logic full,
    output logic[31:0] data32
);

timeunit 1ns;
timeprecision 1ps;

logic [31:0] data;
logic filled;
logic [3:0] byte_counter;
assign full = filled;
assign data32 = data;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data <= '0;
        filled <= '0;
        byte_counter <= 4'b1000;
    end else begin
        if(!rx_empty && !filled && rd_uart) begin
            data[7:0] <= r_data;
            data <= data << 8;
            byte_counter <= {byte_counter[0], byte_counter[3:1]};
        end

        if(byte_counter == 4'b1000) begin
            filled <= 1'b1;
        end else begin
            filled <= 1'b0;
        end
    end
end

endmodule