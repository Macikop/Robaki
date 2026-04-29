/*
 * Designed by MP
 * 
 * How it works:
 * Generates pulse width according to the note
 * 
 */
import note_pkg::*;

module midi_decoder (
    input  logic clk,
    input  logic rst_n,

    input  note_t note_in,
    //input  logic [5:0] note_in,
    input  logic sync_in,
    output logic [7:0] width,
    output logic sync_out
);

    wire [31:0] phase_increment;
    wire [7:0] sine_addr;
    wire sync_from_counter;
    
    logic sync_d;

    phase_increment_lut u_phase_increment_lut(
        .clk,
        .rst_n,

        .note_in(note_in),
        .value(phase_increment)
    );

    address_counter u_address_counter(
        .clk(clk),
        .rst_n(rst_n),
        
        .phase_increment(phase_increment),
        .sync_in(sync_in),

        .sine_addr(sine_addr),
        .sync_out(sync_from_counter)
    );

    sine_lut u_sine_lut(
        .clk,
        .rst_n,

        .addr(sine_addr),
        .value(width)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_d <= '0;
        end else begin
            sync_d <= sync_from_counter;
        end
    end
    
    assign sync_out = sync_d;

endmodule