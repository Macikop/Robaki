/*
 * Designed by MP
 * 
 * How it works:
 * Tests DDS frequency output for all notes
 */

module midi_decoder_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD = 15.3846;     // 65 MHz
    localparam RST_START_TIME  = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;

    /**
     * Signals
     */
    logic clk;
    logic rst_n;

    logic sync_in;
    logic [5:0] note;
    wire [7:0] width;
    wire sync_out;

    int counter;

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

    /**
     * sync_in generator
     */
    initial begin
        sync_in = 0;
        counter = 0;
    end

    always @(posedge clk) begin
        if (!rst_n) begin
            counter <= 0;
            sync_in <= 0;
        end else begin
            if (counter == 255) begin
                sync_in <= 1'b1;
                counter <= 0;
            end else begin
                sync_in <= 1'b0;
                counter <= counter + 1;
            end
        end
    end

    /**
     * DUT
     */
    midi_decoder dut (
        .clk,
        .rst_n,
        .note,
        .sync_in,
        .width,
        .sync_out
    );

    /**
     * Frequency test for one note
     */
    function real midi_freq(input int n);

        return 440.0 * (2.0 ** ((n - 69 + 36) / 12.0));
    endfunction

    task automatic frequency_test(input int n);

        logic last_sign;
        logic curr_sign;

        int cycles;
        int period1, period2;

        real freq;

        note = n;

        repeat (500) @(posedge clk);

        // wait for stable waveform
        last_sign = width[7];

        cycles = 0;
        period1 = 0;

        // first edge
        forever begin
            @(posedge clk);
            cycles++;

            curr_sign = width[7];

            if (curr_sign != last_sign) begin
                period1 = cycles;
                break;
            end
        end

        last_sign = curr_sign;
        cycles = 0;

        // second edge
        forever begin
            @(posedge clk);
            cycles++;

            curr_sign = width[7];

            if (curr_sign != last_sign) begin
                period2 = cycles;
                break;
            end
        end

        freq = 1e9 / ((period1 + period2) * CLK_PERIOD);

        $display("NOTE=%0d | freq=%.2f Hz | expected=%.2f Hz | err=%.2f%%",
            n,
            freq,
            midi_freq(n),
            100.0 * (freq - midi_freq(n)) / midi_freq(n)
        );

    endtask

    /**
     * Main test
     */
    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        for (int n = 0; n < 37; n++) begin
            frequency_test(n);

        end
        $finish;
    end

endmodule