`timescale 1ns / 1ps

module game_uart_encoder_tb();

    // --- Clock and Reset Signals ---
    logic clk;
    logic rst_n;

    // --- Inputs to UUT ---
    logic vsync;
    logic [3:0] current_state;
    logic current_player;
    logic [10:0] worm_1_xpos;
    logic [10:0] worm_1_ypos;
    logic [7:0]  aim_angle;
    logic [7:0]  shot_power;
    logic [10:0] bullet_x;
    logic [10:0] bullet_y;
    logic [7:0]  explosion_radius;
    logic [6:0]  worm_1_health;

    // --- Outputs from UUT ---
    logic [31:0] data32_out;
    logic start;

    // --- Instantiate the Unit Under Test (UUT) ---
    game_uart_encoder uut (
        .clk(clk),
        .rst_n(rst_n),
        .vsync(vsync),
        .current_state(current_state),
        .current_player(current_player),
        .worm_1_xpos(worm_1_xpos),
        .worm_1_ypos(worm_1_ypos),
        .aim_angle(aim_angle),
        .shot_power(shot_power),
        .bullet_x(bullet_x),
        .bullet_y(bullet_y),
        .explosion_radius(explosion_radius),
        .worm_1_health(worm_1_health),
        .data32_out(data32_out),
        .start(start)
    );

    // --- Clock Generation (50 MHz / 20ns period) ---
    always begin
        clk = 1'b0;
        #10;
        clk = 1'b1;
        #10;
    end

    // --- Stimulus Task ---
    // Helper task to apply values and pulse vsync
    task automatic drive_state(
        input logic [3:0] state,
        input logic player
    );
        begin
            @(negedge clk);
            current_state  = state;
            current_player = player;
            
            // Pulse VSYNC for 1 clock cycle to trigger the packet encoding
            vsync = 1'b1;
            @(negedge clk);
            vsync = 1'b0;
            
            // Wait a few cycles to observe the output packet and 'start' clearing
            repeat(2) @(negedge clk);
        end
    endtask

    // --- Main Test Sequence ---
    initial begin
        // Initialize Inputs
        rst_n            = 1'b0;
        vsync            = 1'b0;
        current_state    = 4'd0;
        current_player   = 1'b0;
        worm_1_xpos      = 11'd512;
        worm_1_ypos      = 11'd256;
        aim_angle        = 8'd45;
        shot_power       = 8'd80;
        bullet_x         = 11'd1024;
        bullet_y         = 11'd500;
        explosion_radius = 8'd30;
        worm_1_health    = 7'd100;

        // Reset Pulse
        #40;
        rst_n = 1'b1;
        #20;

        $display("--- Starting Game UART Encoder Simulation ---");

        // Test State 0: Default Empty State
        $display("Testing State 0...");
        drive_state(4'd0, 1'b0);

        // Test State 1: Worm Position Packets
        $display("Testing State 1 (Worm Positions)...");
        drive_state(4'd1, 1'b1);

        // Test State 2: Aim and Power Packets
        $display("Testing State 2 (Aim/Power)...");
        drive_state(4'd2, 1'b0);

        // Test State 3: Bullet Packets
        $display("Testing State 3 (Bullet Positions)...");
        drive_state(4'd3, 1'b1);

        // Test State 4: Explosion Packets
        $display("Testing State 4 (Explosion Radius)...");
        drive_state(4'd4, 1'b0);

        // Test State 5: Empty / Place-holder State
        $display("Testing State 5...");
        drive_state(4'd5, 1'b1);

        // Test State 6: Worm Health Packets
        $display("Testing State 6 (Worm Health)...");
        drive_state(4'd6, 1'b0);

        // --- Corner Case: VSYNC stays high ---
        // Your code uses "if(vsync && !start)". Let's verify 'start' acts like a pulse.
        $display("Testing Corner Case: Long VSYNC pulse...");
        @(negedge clk);
        current_state = 4'd1;
        vsync = 1'b1; // Hold vsync high
        @(negedge clk); // Loop cycles through
        // data32_out updates, 'start' should go high here.
        @(negedge clk); 
        // On next cycle, 'start' should fall back to 0 even if vsync is still 1.
        vsync = 1'b0; 

        repeat(5) @(negedge clk);
        $display("--- Simulation Completed ---");
        $finish;
    end

    // --- Optional Monitor Window ---
    initial begin
        $monitor("Time=%0t ns | State=%0d | Player=%0b | Start=%0b | DataOut=32'b%32b", 
                 $time, current_state, current_player, start, data32_out);
    end

endmodule