/*
 * Designed by MP
 * 
 * How it works:
 * Generates pulse width according to the note
 * 
 */


module midi_decoder (
    input  logic clk,
    input  logic rst_n,

    input  logic [5:0] note,
    input  logic sync_in,
    output logic [7:0] width,
    output logic sync_out
);

    wire [31:0] phase_increment;
    wire [7:0] sine_addr;

    phase_increment_lut u_phase_increment_lut(
        .addr(note),
        .value(phase_increment)
    );

    address_counter u_address_counter(
        .clk(clk),
        .rst_n(rst_n),
        
        .phase_increment(phase_increment),
        .sync_in(sync_in),

        .sine_addr(sine_addr),
        .sync_out(sync_out)
    );

    sine_lut u_sine_lut(
        .addr(sine_addr),
        .value(width)
    );

endmodule