/*
 * Designed by MP
 * 
 * How it works:
 * Tests pwm_generator
 */

module pwm_generator_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.3846;     // 65 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic sync;
    logic [7:0] width;
    wire wave_out;


    int counter;

    /*
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /*
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /*
     * Sync generation
     */

    initial begin
        sync = 0;
        counter = 0;
        @(negedge rst_n);
        @(posedge rst_n);
        sync = 0;
        counter = 0;

        forever begin
            @(posedge clk);
            if (counter == 255) begin
                sync <= 1'b1;
                counter <= '0;
            end else begin
                sync <= 1'b0;
                counter <= counter + 1;
            end
        end
    end

    /*
     * Dut placement
     */

    pwm_generator dut(
        .clk,
        .rst_n,
        .sync,
        .width,
        .wave_out
    );

    /**
     * Tasks and functions
     */

    task width_test();
        int high_cycles;

        for (int pulse_width = 0; pulse_width < 256; pulse_width++) begin

            @(posedge sync)
            width <= pulse_width[7:0];

            high_cycles = 0;

            for (int i = 0; i < 256; i++) begin
                @(posedge clk);
                if (wave_out)
                    high_cycles++;
            end

            if (high_cycles !== pulse_width) begin
                $error("Width=%0d FAILED expected=%0d got=%0d", pulse_width, pulse_width, high_cycles);
            end else begin
                $display("Width=%0d OK", pulse_width);
            end

        end
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

        width_test();

        $finish;
    end

endmodule
