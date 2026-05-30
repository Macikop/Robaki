/*
 * Designed by MP
 * 
 * Description:
 * Testbench for rng module.
 */

module rng_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam WIDTH = 32;


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic [WIDTH-1:0]random_number;

    

    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
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
     * Dut placement
     */

    rng #(
        .OUTPUT_WIDTH(WIDTH),
        .SEED(32'hACE1),                /* starting condition for first stage */
        .SPREAD(32'h5555_5555)          /* just to change starting conditions for other stages */
    ) dut (
        .clk,
        .rst_n,
        .random_number(random_number)
    );

    /**
     * Tasks and functions
     */
    
    task automatic check_chi_square(input int num_samples);
        localparam int NUM_BINS = 64;
        localparam int BIN_SHIFT = WIDTH - 6;
        
        int observed_counts[NUM_BINS];
        real expected_count;
        real chi_square_stat;
        real bin_diff;
        int bin_index;
        
        real CRITICAL_VALUE = 82.53;    /* 63 DoF at 95% confidence */

        for (int i = 0; i < NUM_BINS; i++) begin
            observed_counts[i] = 0;
        end
        
        expected_count = real'(num_samples) / real'(NUM_BINS);
        chi_square_stat = 0.0;

        /* dividing samples into groupes uing MSB */
        for (int s = 0; s < num_samples; s++) begin
            @(posedge clk);
            bin_index = random_number >> BIN_SHIFT;
            observed_counts[bin_index]++;
        end

        /* statistics calculations - does number of items in each bin is similar*/
        for (int i = 0; i < NUM_BINS; i++) begin
            bin_diff = real'(observed_counts[i]) - expected_count;
            chi_square_stat += (bin_diff * bin_diff) / expected_count;
        end

        $display("\n================== CHI-SQUARE TEST REPORT ==================");
        $display(" Total Samples Checked : %0d", num_samples);
        $display(" Expected Per Bin     : %0.2f", expected_count);
        $display(" Calculated Chi2 Stat : %0.4f", chi_square_stat);
        $display(" Critical Value Limit : %0.2f", CRITICAL_VALUE);
        $display("============================================================");
        
        
        assert (
            chi_square_stat < CRITICAL_VALUE
        ) begin
            $display("PASSED: The distribution is mathematically uniform."); 
        end else begin
            $error ("FAILED: The distribution deviates significantly from uniform.");
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

        check_chi_square(1000_000);

        $finish;
    end

endmodule
