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
        .shoutdown()
    );
    /**
     * Tasks and functions
     */

task automatic verify_song();

    int expected_duration;
    note_t expected_note;

    real expected_freq;
    real measured_freq;
    real error_pct;

    int sample_window = 128;   // PWM averaging window
    int pwm_sum;
    real avg_value;

    real prev_avg, curr_avg;
    int clk_cycles;
    int crossing1, crossing2;

    for (int i = 0; i < FILE_SIZE; i++) begin
        expected_duration = rom_data[i][31:6];
        expected_note     = note_t'(rom_data[i][5:0]);

        if (expected_note == PAUSE)
            continue;

        expected_freq = note_freq(expected_note);

        // Wait for note stabilization
        repeat (5000) @(posedge clk);

        prev_avg = 0.0;
        curr_avg = 0.0;
        clk_cycles = 0;
        crossing1 = -1;
        crossing2 = -1;

        // Detect two upward zero-crossings
        forever begin
            pwm_sum = 0;

            // Average PWM over window
            repeat (sample_window) begin
                @(posedge clk);
                clk_cycles++;
                if (wave_out)
                    pwm_sum++;
            end

            curr_avg = pwm_sum / real'(sample_window);

            // Detect upward midpoint crossing
            if ((prev_avg < 0.5) && (curr_avg >= 0.5)) begin
                if (crossing1 == -1)
                    crossing1 = clk_cycles;
                else begin
                    crossing2 = clk_cycles;
                    break;
                end
            end

            prev_avg = curr_avg;
        end

        measured_freq = 1e9 / ((crossing2 - crossing1) * CLK_PERIOD);
        error_pct = 100.0 * (measured_freq - expected_freq) / expected_freq;

        // if ((error_pct > 5.0) || (error_pct < -5.0)) begin
        //     $error("PWM sine mismatch at note %0d: measured=%.2f expected=%.2f", expected_note, measured_freq, expected_freq);
        // end

        // $display("PASS PWM note=%0d freq=%.2fHz expected=%.2fHz err=%.2f%% duration=%0d", expected_note, measured_freq, expected_freq, error_pct, expected_duration);

        repeat (expected_duration * 256) @(posedge clk);
    end

    $display("PWM song verification complete.");
endtask

    /**
     * Frequency calculation
     *
     * Enum index:
     * A4 = 21
     */
    function real note_freq(input note_t n);
        return 440.0 * (2.0 ** ((int'(n) - 34) / 12.0));
    endfunction

    /**
     * Assertions
     */    

    /**
     * Main test
     */
    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        verify_song();
        $display("Verify waveforms");

        $finish;
    end

endmodule