`timescale 1ns / 1ps

module uart_packet_slicer_tb();

    // --- Clock and Reset Signals ---
    logic clk;
    logic rst_n;

    // --- Inputs to UUT ---
    logic        done;
    logic [31:0] packet;

    // --- Outputs from UUT ---
    logic [3:0]  current_state;
    logic        current_player;
    logic [2:0]  extra;
    logic [23:0] payload;

    // --- Instantiate the Unit Under Test (UUT) ---
    uart_packet_slicer uut (
        .clk(clk),
        .rst_n(rst_n),
        .done(done),
        .packet(packet),
        .current_state(current_state),
        .current_player(current_player),
        .extra(extra),
        .payload(payload)
    );

    // --- Clock Generation (50 MHz / 20ns period) ---
    always begin
        clk = 1'b0;
        #10;
        clk = 1'b1;
        #10;
    end

    // --- Stimulus & Verification Task ---
    task automatic send_and_verify(
        input logic [3:0]  exp_state,
        input logic        exp_player,
        input logic [2:0]  exp_extra,
        input logic [23:0] exp_payload
    );
        logic [31:0] full_packet;
        begin
            // Assemble the packet based on your specification layout
            full_packet = {exp_state, exp_player, exp_extra, exp_payload};

            @(negedge clk);
            packet = full_packet;
            done   = 1'b1; // Pulse done to signal a completed UART reception

            @(negedge clk);
            done   = 1'b0; // Clear done flag
            packet = 'x;   // Set to don't care to ensure outputs hold their values

            // Wait 1 cycle for the sequential logic inside UUT to capture data
            @(posedge clk);
            #1; // Minor settling delay for sampling stability

            // Direct assertions to check accuracy
            assert(current_state  === exp_state)  else $error("State Mismatch! Exp: %h, Got: %h", exp_state, current_state);
            assert(current_player === exp_player) else $error("Player Mismatch! Exp: %b, Got: %b", exp_player, current_player);
            assert(extra          === exp_extra)  else $error("Extra Mismatch! Exp: %h, Got: %h", exp_extra, extra);
            assert(payload        === exp_payload) else $error("Payload Mismatch! Exp: %h, Got: %h", exp_payload, payload);
        end
    endtask

    // --- Main Test Sequence ---
    initial begin
        // Initialize Inputs
        rst_n  = 1'b0;
        done   = 1'b0;
        packet = '0;

        // Reset Sequence
        #40;
        rst_n = 1'b1;
        #20;

        $display("--- Starting UART Packet Slicer Simulation ---");

        // Test Case 1: Standard Values (Simulating State 1: Worm Positions)
        $display("TC1: Sending State 1 data packet...");
        send_and_verify(4'd1, 1'b1, 3'b000, 24'hA5A5A5);

        // Test Case 2: Maxed Values (Simulating State 2: Aim & Power)
        $display("TC2: Sending State 2 maxed data packet...");
        send_and_verify(4'd2, 1'b0, 3'b111, 24'hFFFFFF);

        // Test Case 3: Alternating Bit Patterns
        $display("TC3: Sending Alternating bit pattern packet...");
        send_and_verify(4'hA, 1'b1, 3'b010, 24'h555555);

        // Test Case 4: Output Hold check (Ensure outputs don't change if done=0)
        $display("TC4: Verifying data hold when 'done' is low...");
        @(negedge clk);
        packet = 32'hFFFFFFFF; // Random new packet arriving on lines
        done   = 1'b0;         // But done remains low
        repeat(2) @(posedge clk);
        
        // Outputs should still match the values from TC3
        assert(current_state === 4'hA) else $error("Hold Failure on State!");
        assert(payload === 24'h555555) else $error("Hold Failure on Payload!");

        #20;
        $display("--- Simulation Completed Successfully ---");
        $finish;
    end

    // --- Optional Monitor Window ---
    initial begin
        $monitor("Time=%0t ns | Done=%b | Pkt=%8h | State=%h | Player=%b | Extra=%b | Payload=%6h", 
                 $time, done, uut.packet, current_state, current_player, extra, payload);
    end

endmodule