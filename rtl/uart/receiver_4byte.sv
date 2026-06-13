module receiver_4byte(
    input logic clk,
    input logic rst_n,
    input logic rx_empty,
    output logic rd_uart,
    input logic[7:0] r_data,
    output logic full,
    output logic[31:0] data32
);

timeunit 1ns;
timeprecision 1ps;

logic [31:0] data;
logic filled;
logic [1:0] byte_counter;

assign full = filled;
assign data32 = data;
assign rd_uart = (!rx_empty && !filled);

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        data <= '0;
        filled <= '0;
        byte_counter <= '0;
    end else begin
        if(rd_uart) begin
            data <= {r_data, data32[31:8]};
            byte_counter <= byte_counter + 1;

            if(byte_counter == 3'd3) begin
                filled <= 1'b1;
            end else begin
                filled <= 1'b0;
            end
        end
    end
end

endmodule