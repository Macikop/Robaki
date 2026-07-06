/*  Designed by KS
 *  
 *  slices 32-bit packets from 4-byte UART into segments
 *  packet : |current_state|current_player|extra|payload|
 *  current_state : 4 bits
 *  current_player : 1 bit
 *  extra : 3 bits
 *  payload : 24 bits
 */

module uart_packet_slicer(
    input logic clk,
    input logic rst_n,

    input logic done,
    input logic [31:0] packet,

    output logic [3:0] current_state,
    output logic current_player,
    output logic [2:0] extra,
    output logic [23:0] payload
    );

    timeunit 1ns;
    timeprecision 1ps;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= '0;
            current_player <= '0;
            extra <= '0;
            payload <= '0;
        end else begin
            if(done) begin
                current_state <= packet[31:28];
                current_player <= packet[27];
                extra <= packet[26:24];
                payload <= packet[23:0];
            end
        end
    end

endmodule