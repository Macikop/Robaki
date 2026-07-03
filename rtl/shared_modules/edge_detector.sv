/* 
 * Copyright (C) 2025 AGH University of Krakow 
 * Modified by MP
 * Added parameter to change edge type
 */

module edge_detector #(
    parameter logic POSITIVE = 1'b1
)(
    input  logic clk,
    input  logic rst_n,
    input  logic din,
    output logic edge_detected
);
    /* Local variables and signals */
    logic din_buf;

    /* Module internal logic */
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            din_buf <= 1'b0;
        end else begin
            din_buf <= din;
        end
    end

    /* Combinational logic qualified by reset */
    always_comb begin
        if (!rst_n) begin
            edge_detected = 1'b0;
        end else begin
            edge_detected = POSITIVE ? (din & ~din_buf) : (~din & din_buf);
        end
    end

endmodule