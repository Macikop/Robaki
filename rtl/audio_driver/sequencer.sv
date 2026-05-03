/*
 *  Designed by MP
 * 
 * How it works
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

    logic [$clog2(FILE_SIZE):0] addres_nxt;


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sync_out <= '0;
            counter <= '0;
            address <= '0;
        end else begin
            sync_out <= sync_in;
            note_out <= note_nxt;
            counter <= counter_nxt;
            address <= addres_nxt;
        end
    end

    always_comb begin
        if (sync_in) begin
            if (counter == 0) begin
                counter_nxt = word[31:6];      //note lenght
                note_nxt = note_t'(word[5:0]);
                addres_nxt = address + 1;
            end else begin
                counter_nxt = counter - 1;
                note_nxt = note_out;
                addres_nxt = address;
            end
        end else begin
            note_nxt = note_out;
            counter_nxt = counter;
            addres_nxt = address;
        end
    end

endmodule
