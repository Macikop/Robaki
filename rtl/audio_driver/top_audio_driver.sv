/*
 * Designed by MP
 * 
 * How it works:
 * This module is compleated module for audio driver. Reads notes saved in .hex file and outputs pwm for pmodamp2
 */

import note_pkg::*;

module top_audio_driver #(
    parameter FILE_SIZE = 14,
    parameter FILE_PATH = "../../rtl/audio_driver/music_files/nokia_ringtone.hex"
)(
    input  logic clk,       /* this module is using 65MHz clock */
    input  logic rst_n,

    input  logic mute,
    input  logic volume,

    output logic wave_out,
    output logic gain,
    output logic shoutdown
);

    timeunit 1ns;
    timeprecision 1ps;

    /*
     * Local variables and signals
     */

    wire [31:0] rom_word;
    wire [$clog2(FILE_SIZE):0] rom_address;

    wire [7:0] pwm_width;

    wire sync1, sync2, sync3;

    note_t current_note;


    /**
     * Signals assignments
     */

    assign shoutdown = ~mute;
    assign gain = ~volume;

    /**
     * Submodules instances
     */

    sync_generator u_sync_generator(
        .clk,
        .rst_n,
        .sync(sync1)
    );

    sequencer #(
        .FILE_SIZE(FILE_SIZE)
    ) u_sequencer (
        .clk,
        .rst_n,

        .sync_in(sync1),
        .word(rom_word),

        .sync_out(sync2),
        .address(rom_address),

        .note_out(current_note)
    );

    music_rom #(
        .FILE_SIZE(FILE_SIZE),
        .FILE_PATH(FILE_PATH)
    ) u_music_rom (
        .clk,
        .rst_n,

        .address(rom_address),
        .value(rom_word)
    );

    midi_decoder u_midi_decoder (
        .clk,
        .rst_n,

        .sync_in(sync2),
        .note_in(current_note),

        .width(pwm_width),
        .sync_out(sync3)

    );

    pwm_generator u_pwm_generator (
        .clk,
        .rst_n,

        .sync(sync3),
        .width(pwm_width),

        .wave_out(wave_out)
    );

endmodule
