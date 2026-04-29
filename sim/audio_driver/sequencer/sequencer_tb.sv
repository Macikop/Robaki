/*
 * Designed by MP
 * 
 * How it works:
 * Tests sequencer
 */

module sequencer_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import note_pkg::*;

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

    logic sync, sync_out;
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
    end
    

    always @(posedge clk) begin
        if (counter == 255) begin
            sync <= 1'b1;
            counter <= '0;
        end else begin
            sync <= 1'b0;
            counter <= counter + 1;
        end
    end

    /*
     * Dut placement
     */

    sequencer #(
        .FILE_SIZE(16)
    )dut(
        .clk,
        .rst_n,
        .sync_in(sync),
        .word(),
        .sync_out(sync_out),
        .address(),
        .note_out()
    );

    /**
     * Tasks and functions
     */

    task automatic random_note();
        logic [25:0] note_length;
        note_t current_note;

        note_length = $urandom_range(33_554_432, 1);
        current_note = note_t'($urandom_range(37, 0));
        
    endtask
    

    /**
     * Assertions
     */

    assert property (
        @(posedge clk) 
        disable iff (!rst_n || $realtime < RST_START_TIME)
        sync_out == $past(sync)
    ) else begin
        $error("Sync is not delayed by 1 clk");
    end

    // assign sync_out = sync;

    /**
     * Main test
     */

    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        repeat(1000) begin
            @(posedge clk);
        end
        

        $finish;
    end

endmodule
