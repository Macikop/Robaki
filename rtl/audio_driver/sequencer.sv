/*
 * Designed by MP
 * 
 * How it works:
 * Outputs sequence of notes according to it's lenght
 */

import note_pkg::*;

module sequencer #(
    parameter FILE_SIZE = 14
)(
    input  logic clk,
    input  logic rst_n,

    input  logic sync_in,
    input  logic [31:0] word,

    output logic sync_out,
    output logic [$clog2(FILE_SIZE):0] address,
    output note_t note_out
);

    logic [25:0] counter, counter_nxt;
    note_t note_nxt;

    logic [$clog2(FILE_SIZE):0] address_nxt;
    logic sync_in_d;
    logic [31:0] word_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_out <= '0;
            sync_in_d <= '0;
            word_d <= '0;
            counter <= '0;
            address <= '0;
            note_out <= PAUSE;
        end else begin
            sync_in_d <= sync_in;
            word_d <= word;

            sync_out <= sync_in_d;
            note_out <= note_nxt;
            counter <= counter_nxt;
            address <= address_nxt;
        end
    end

    always_comb begin
        counter_nxt = counter;
        note_nxt = note_out;
        address_nxt = address;

        if (sync_in_d) begin
            if (counter == 0) begin
                counter_nxt = word_d[31:6];      // note length
                note_nxt = note_t'(word_d[5:0]);
                address_nxt = (address == FILE_SIZE-1) ? 0 : address + 1;
            end else begin
                counter_nxt = counter - 1;
            end
        end
    end

endmodule
