module top_4byte_uart(
    input logic clk,
    input logic rst_n,
    input logic[31:0] data_transmit,
    input logic rx,
    output logic done,
    output logic[31:0] data_received,
    output logic tx
);

timeunit 1ns;
timeprecision 1ps;

wire wr_uart, tx_full, empty, rx_empty, rd_uart, full;
wire[7:0] w_data, r_data;

uart #(
    .DVSR(54)
)u_uart(
    .clk,
    .reset(~rst_n),
    .rd_uart(rd_uart), 
    .wr_uart(wr_uart), 
    .rx(rx),
    .w_data(w_data),
    .tx_full(tx_full), 
    .rx_empty(rx_empty), 
    .tx(tx),
    .r_data(r_data)
);

transmitter_4byte u_transmitter_4byte(
    .clk,
    .rst_n,
    .data32(data_transmit),
    .tx_full(tx_full),
    .wr_uart(wr_uart),
    .w_data(w_data),
    .empty(empty)
);

receiver_4byte u_receiver_4byte(
    .clk,
    .rst_n,
    .rx_empty(rx_empty),
    .rd_uart(rd_uart),
    .r_data(r_data),
    .full(full),
    .data32(data_received)
);

endmodule