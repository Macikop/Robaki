/*
 * Designed by MP
 *
 * How it works:
 * Tests DDS frequency output for all notes
 */

module top_audio_driver_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import note_pkg::*;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD = 15.3846;     // 65 MHz
    localparam RST_START_TIME  = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;

    localparam FILE_SIZE = 14;
    localparam FILE_PATH = "../../rtl/audio_driver/music_files/nokia_ringtone.hex";

    /**
     * Signals
     */
    logic clk;
    logic rst_n;
    logic wave_out;

    logic [31:0] rom_data [0:FILE_SIZE - 1];

    initial begin
        $readmemh(FILE_PATH, rom_data);
    end
    

    /**
     * Clock generation
     */
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    /**
     * Reset generation
     */
    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /*
     * Dut placement
     */

    top_audio_driver #(
        .FILE_SIZE(FILE_SIZE),
        .FILE_PATH(FILE_PATH)
    ) dut(
        .clk,
        .rst_n,

        .mute('0),
        .volume('0),

        .wave_out(wave_out),
        .gain(),
        .shutdown()
    );
    /**
     * Tasks and functions
     */

    task automatic play_song();

        for (int i = 0; i < FILE_SIZE; i++) begin

            int duration;
            note_t note;

            duration = rom_data[i][31:6];
            note     = note_t'(rom_data[i][5:0]);

            $display("Playing note %0d duration %0d", note, duration);

            if (note == PAUSE) begin
                repeat (duration * 256) @(posedge clk);
                continue;
            end

            repeat (2000) @(posedge clk);

            repeat (1024) begin
                @(posedge clk);
            end

            repeat (duration * 256) @(posedge clk);

        end

        $display("Song playback finished.");
    endtask

    /**
     * Assertions
     */    

    /**
     * Main test
     */
    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        play_song();
        $display("Verify waveforms");

        $finish;
    end

endmodule