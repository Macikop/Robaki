/*
 * Designed by MP
 * 
 * Description:
 * Testbench for master_fsm module.
 */

module master_fsm_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    
    logic space_bar;

    logic space_bar_last;
    logic space_bar_last_last;
    logic posedge_occured;

    assign space_bar_last = dut.space_bar_last;
    assign space_bar_last_last = dut.space_bar_last_last;
    assign posedge_occured = dut.posedge_occured;

    logic vsync_in;
    logic [6:0] worm_health [0:1];
    logic worms_on_ground [0:1];
    logic bullet_impact;
    logic explosion_done;

    logic sync_out;
    logic start_screen_en;
    logic walking_en;
    logic shooting_en;
    logic bullet_en;
    logic explosion_en;
    logic end_screen_en;
    logic capture_wind;
    logic current_player;

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

    initial begin
        vsync_in = 1'b0;
        forever begin
            repeat(4) @(posedge clk);
            vsync_in = 1'b1;
            @(posedge clk);
            vsync_in = 1'b0;
        end
    end


    /**
     * Dut placement
     */
    
    master_fsm dut (
        .clk             (clk),
        .rst_n           (rst_n),
        .space_bar       (space_bar),
        .vsync_in        (vsync_in),
        .worm_health     (worm_health),
        .worms_on_ground (worms_on_ground),
        .bullet_impact   (bullet_impact),
        .explosion_done  (explosion_done),
        .sync_out        (sync_out),
        .start_screen_en (start_screen_en),
        .walking_en      (walking_en),
        .shooting_en     (shooting_en),
        .bullet_en       (bullet_en),
        .explosion_en    (explosion_en),
        .end_screen_en   (end_screen_en),
        .capture_wind    (capture_wind),
        .current_player  (current_player)
    );

    /**
     * Tasks and functions
     */

    task automatic press_space_for_syncs(input int sync_count);
        if (sync_count <= 0) return;

        @(negedge clk);
        space_bar = 1'b1;
        $display("Space Bar Pressed. Holding for %0d VSYNCs...", sync_count);

        repeat (sync_count) begin
            @(posedge vsync_in);
        end

        @(negedge clk);
        space_bar = 1'b0;
        $display("Space Bar Released.");
        
        repeat(2) @(posedge clk); 
    endtask

    task automatic initialize_signals();
        space_bar          = 1'b0;
        worm_health[0]     = 7'd100;
        worm_health[1]     = 7'd100;
        worms_on_ground[0] = 1'b1;
        worms_on_ground[1] = 1'b1;
        bullet_impact      = 1'b0;
        explosion_done     = 1'b0;
    endtask

    task automatic test_game_start();
        $display("Starting test_game_start...");
        
        press_space_for_syncs(1);
        @(posedge clk);
        
        assert (walking_en === 1'b1) 
            $display("PASSED: Successfully transitioned to WALKING state enable.");
        else 
            $error("FAILED: Failed to enter WALKING state enable.");
    endtask

    task automatic test_firing_sequence();
        $display("Starting test_firing_sequence...");

        press_space_for_syncs(3);
        
        assert (shooting_en === 1'b1)
            $display("PASSED: Successfully entered SHOOTING state enable.");
        else 
            $error("FAILED: Failed to enter SHOOTING state enable.");

        @(posedge vsync_in);
        repeat(3) @(posedge clk);
        
        assert (bullet_en === 1'b1)
            $display("PASSED: Successfully entered BULLET_FLIGHT state enable.");
        else 
            $error("FAILED: Failed to enter BULLET_FLIGHT state enable.");
    endtask

    task automatic test_player_switch();
        logic original_player;
        $display("Starting test_player_switch...");
        
        original_player = current_player;

        bullet_impact = 1'b1;
        @(posedge vsync_in);
        @(posedge clk);
        bullet_impact = 1'b0;

        explosion_done = 1'b1;
        @(posedge vsync_in);
        @(posedge clk);
        explosion_done = 1'b0;

        @(posedge vsync_in);
        @(posedge clk);

        assert (walking_en === 1'b1 && (current_player != original_player))
            $display("PASSED: Active player successfully toggled from %0d to %0d and returned to walking.", original_player, current_player);
        else 
            $error("FAILED: Player switch calculation failed. walking_en=%b, player=%b", walking_en, current_player);
    endtask

    initial begin
        initialize_signals();
        $monitor("%b, %b, %b", dut.space_bar_last, dut.space_bar_last_last, dut.posedge_occured);

        @(negedge rst_n);
        @(posedge rst_n);
        repeat(5) @(posedge clk);

        test_game_start();
        repeat(5) @(posedge clk);

        test_firing_sequence();
        repeat(5) @(posedge clk);

        test_player_switch();
        repeat(5) @(posedge clk);

        $finish;
    end

endmodule