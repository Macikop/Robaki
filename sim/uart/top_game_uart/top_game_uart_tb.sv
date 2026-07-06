`timescale 1ns / 1ps

module top_game_uart_tb();

    logic clk;
    logic rst_n;
    logic vsync;


    logic [3:0]  current_state_tx;
    logic        current_player_tx;
    logic [10:0] worm_1_xpos_tx;
    logic [10:0] worm_1_ypos_tx;
    logic [7:0]  aim_angle_tx;
    logic [7:0]  shot_power_tx;
    logic [10:0] bullet_x_tx;
    logic [10:0] bullet_y_tx;
    logic [7:0]  explosion_radius_tx;
    logic [6:0]  worm_1_health_tx;

    logic serial_line;

    logic [3:0]  current_state_rx;
    logic        current_player_rx;
    logic [10:0] worm_1_xpos_rx;
    logic [10:0] worm_1_ypos_rx;
    logic [7:0]  aim_angle_rx;
    logic [7:0]  shot_power_rx;
    logic [10:0] bullet_x_rx;
    logic [10:0] bullet_y_rx;
    logic [7:0]  explosion_radius_rx;
    logic [6:0]  worm_1_health_rx;

    logic done_tx;
    logic empty;

    // --- Instantiate Unit Under Test (UUT) ---
    top_game_uart u_top_game_uart (
        .clk(clk),
        .rst_n(rst_n),
        .vsync(vsync),
        .empty(empty),

        // Tx Inputs
        .current_state_tx(current_state_tx),
        .current_player_tx(current_player_tx),
        .worm_1_xpos_tx(worm_1_xpos_tx),
        .worm_1_ypos_tx(worm_1_ypos_tx),
        .aim_angle_tx(aim_angle_tx),
        .shot_power_tx(shot_power_tx),
        .bullet_x_tx(bullet_x_tx),
        .bullet_y_tx(bullet_y_tx),
        .explosion_radius_tx(explosion_radius_tx),
        .worm_1_health_tx(worm_1_health_tx),

        //serial loopback
        .rx(serial_line),
        .tx(serial_line),
        .done_tx(done_tx),

        // Rx Outputs
        .current_state_rx(current_state_rx),
        .current_player_rx(current_player_rx),
        .worm_1_xpos_rx(worm_1_xpos_rx),
        .worm_1_ypos_rx(worm_1_ypos_rx),
        .aim_angle_rx(aim_angle_rx),
        .shot_power_rx(shot_power_rx),
        .bullet_x_rx(bullet_x_rx),
        .bullet_y_rx(bullet_y_rx),
        .explosion_radius_rx(explosion_radius_rx),
        .worm_1_health_rx(worm_1_health_rx)
    );

    initial begin
        clk = 1'b0;
    end

    always begin 
        clk = ~clk;
        #5;
    end

    task automatic transmit_packet(
        input logic [3:0]  state,
        input logic        player,
        input logic [10:0] wx, wy,
        input logic [7:0]  angle, power,
        input logic [10:0] bx, by,
        input logic [7:0]  er,
        input logic [6:0]  hp
    );
        begin
            @(negedge clk);
            $display("starting task at %0t ns", $time);
            current_state_tx    = state;
            current_player_tx   = player;
            worm_1_xpos_tx      = wx;
            worm_1_ypos_tx      = wy;
            aim_angle_tx        = angle;
            shot_power_tx       = power;
            bullet_x_tx         = bx;
            bullet_y_tx         = by;
            explosion_radius_tx = er;
            worm_1_health_tx    = hp;

            @(negedge clk);
            // Trigger transmission with vsync
            $display("[TX] Sending State %0d Packet via UART loopback...", state);
            $display("Pulsing VSYNC at time %0t ns", $time);
            vsync = 1'b1;
            @(negedge clk);
            @(negedge clk);
            vsync = 1'b0;
            $display("VSYNC to 0 at time %0t ns", $time);
            @(negedge clk);
        end
    endtask

    initial begin

        rst_n = 1'b0;
        vsync = 1'b0;
        
        current_state_tx    = '0;
        current_player_tx   = '0;
        worm_1_xpos_tx      = '0;
        worm_1_ypos_tx      = '0;
        aim_angle_tx        = '0;
        shot_power_tx       = '0;
        bullet_x_tx         = '0;
        bullet_y_tx         = '0;
        explosion_radius_tx = '0;
        worm_1_health_tx    = '0;


        #100;
        rst_n = 1'b1;
        #40;

        $display("--- Starting Top Game UART Loopback Simulation ---");

        // --- Test Case 1: Worm 1 Positions (State 1) ---
        transmit_packet(.state(4'd1), .player(1'b1), .wx(11'd725), .wy(11'd340), 
                        .angle(8'd0), .power(8'd0), .bx(11'd0), .by(11'd0), .er(8'd0), .hp(7'd0));
        
        // Wait for the internal 'done' signal to high
        
        if(!done_tx) begin
            @(posedge done_tx);
        end 
        repeat(3) @(posedge clk);
        #1;
        
        // Self-checking logic for State 1
        assert(current_state_rx === 4'd1) else $error("[RX Error] State Mismatch!");
        assert(current_player_rx === 1'b1) else $error("[RX Error] Player Mismatch!");
        assert(worm_1_xpos_rx === 11'd725 && worm_1_ypos_rx === 11'd340) else $error("[RX Error] Coordinates Mismatch!");
        $display("[SUCCESS] State 1 successfully looped back! X=%0d, Y=%0d", worm_1_xpos_rx, worm_1_ypos_rx);

        #200;
        rst_n = 1'b0;
        repeat(2) @(negedge clk);
        rst_n = 1'b1;

        // --- Test Case 2: Weapon Aim & Power (State 2) ---
        transmit_packet(.state(4'd2), .player(1'b0), .wx(11'd0), .wy(11'd0), 
                        .angle(8'd65), .power(8'd92), .bx(11'd0), .by(11'd0), .er(8'd0), .hp(7'd0));
        
        if(!done_tx) begin
            @(posedge done_tx);
        end 
        repeat(3) @(posedge clk);
        #1;

        // Self-checking logic for State 2
        assert(current_state_rx === 4'd2) else $error("[RX Error] State Mismatch!");
        assert(aim_angle_rx === 8'd65 && shot_power_rx === 8'd92) else $error("[RX Error] Aim/Power Mismatch!");
        // State 1 parameters (positions) 
        $display("[SUCCESS] State 2 successfully looped back! Angle=%0d, Power=%0d", aim_angle_rx, shot_power_rx);

        #200;
        rst_n = 1'b0;
        repeat(2) @(negedge clk);
        rst_n = 1'b1;

        // --- Test Case 3: Worm Health updates (State 6) ---
        transmit_packet(.state(4'd6), .player(1'b0), .wx(11'd0), .wy(11'd0), 
                        .angle(8'd0), .power(8'd0), .bx(11'd0), .by(11'd0), .er(8'd0), .hp(7'd85));
        
        if(!done_tx) begin
            @(posedge done_tx);
        end 
        repeat(3) @(posedge clk);
        #1;

        assert(current_state_rx === 4'd6) else $error("[RX Error] State Mismatch!");
        assert(worm_1_health_rx === 7'd85) else $error("[RX Error] Health Mismatch!");
        $display("[SUCCESS] State 6 successfully looped back! Health=%0d", worm_1_health_rx);

        #500;
        $display("--- Simulation Completed Successfully ---");
        $finish;
    end

endmodule