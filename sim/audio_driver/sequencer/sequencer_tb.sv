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

    localparam FILE_SIZE = 38;


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic sync, sync_out;

    wire [$clog2(FILE_SIZE):0] address;
    note_t note_out;
    logic [31:0] word;

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
        .FILE_SIZE(FILE_SIZE)
    )dut(
        .clk,
        .rst_n,
        .sync_in(sync),
        .word(word),
        .sync_out(sync_out),
        .address(address),
        .note_out(note_out)
    );

    /**
     * Tasks and functions
     */

    task automatic check_note_length();
        logic [25:0] note_length;
        note_t current_note;

        int note_cycle_count;

        logic [$clog2(FILE_SIZE):0] prev_address;

        prev_address = address;

        for (int i=0; i<38; i++) begin
            note_length = $urandom_range(1000, 1);
            current_note = note_t'(i);

            word = {note_length, current_note};

            @(posedge clk);
            while (address == prev_address) begin
                @(posedge clk);
            end

            prev_address = address;

            note_cycle_count = 0;

            while (note_cycle_count < note_length) begin
                @(posedge clk);

                if(sync) begin
                    if (note_out !== current_note) begin
                        $error("ERROR: Expected note %0d got %0d at cycle %0d", current_note, note_out, note_cycle_count);
                    end 
                    note_cycle_count ++;
                end
            end
            @(posedge clk);
            if (sync && (note_out == current_note)) begin
                $error("ERROR: Note %0d lasted too long (>%0d cycles)", current_note, note_length);
            end
            
            $display("PASS: Note %0d played correctly for %0d cycles", current_note, note_length);
        end
        $display("All notes verified successfully.");
    endtask
    

    /**
     * Assertions
     */

    assert property (
        @(posedge clk) 
        disable iff (!rst_n || $realtime < RST_START_TIME)
        sync_out == $past(sync, 2)
    ) else begin
        $error("Sync is not delayed by 1 clk");
    end

    /**
     * Main test
     */

    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        check_note_length();

        $finish;
    end

endmodule
