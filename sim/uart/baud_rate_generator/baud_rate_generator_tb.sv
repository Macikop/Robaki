`timescale 1ns / 1ps

module baud_rate_generator_tb;

    // Inputs
    logic clk;
    logic rst_n;

    // Outputs
    logic baud_tick;

    baud_rate_generator #(
        .CLK_FREQUENCY(100_000_000), // 100 MHz
        .BAUD_RATE(115200)      // Divisor = 54
    ) u_baud_rate_generator (
        .clk100MHz(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    // 100 MHz Clock Generation (10ns period)
    always begin
        clk = 1'b0;
        #5;
        clk = 1'b1;
        #5;
    end

    // Track clock cycles between ticks to verify divisor
    int cycle_count = 0;
    int tick_count = 0;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            cycle_count <= 0;
        end else begin
            cycle_count <= cycle_count + 1;
            if (baud_tick) begin
                $display("[TICK %0d] Generated at cycle count: %0d (Expected: +-54)", ++tick_count, cycle_count);
                // Self-checking assertion
                if (cycle_count != 54 && cycle_count != 53) begin
                    $error("ERROR: Expected tick spacing of 54 cycles, got %0d", cycle_count);
                end
                cycle_count <= 0; // Reset counter for next interval
            end
        end
    end

    // Test Sequence
    initial begin
        rst_n = 1'b0;
        #20;
        rst_n = 1'b1; // Release reset
        
        // Let simulation run long enough to capture multiple ticks
        // 54 cycles * 10ns = 540ns per tick
        #5000;
        
        $display("Baud generator testbench finished.");
        $finish;
    end

endmodule