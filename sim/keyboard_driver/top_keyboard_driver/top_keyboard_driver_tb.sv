/*
 * Designed by KS
 * 
 * How it works:
 * SImulates PS/2 Serial protocol to verify keyboard scan code decoding
 * into directional functional flags
 * 
 */

module top_keyboard_driver_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */

    localparam CLK_PERIOD           = 10.0; // 100MHz
    localparam PS2_BIT_PERIOD       = 80000; // 12.5 kHz PS2 clock (about 80us)
    localparam RST_START_TIME       = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME      = 2.00 * CLK_PERIOD;

    /**
     * Signals
     */

    logic clk;
    logic rst_n;
    logic ps2_clk;
    logic ps2_data;

    //DUT outputs
    wire up, down, left, right, space, tab;

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
     * Signal initialization
     */

    initial begin
        ps2_clk = 1'b1;
        ps2_data = 1'b1;
    end

     /**
     * Dut Placement
     */

    top_keyboard_driver dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .ps2_clk    (ps2_clk),
        .ps2_data   (ps2_data),
        .up         (up),
        .down       (down),
        .left       (left),
        .right      (right),
        .space      (space),
        .tab        (tab)
    );
    
    /**
     * Tasks
     *      
     */

    /**
     * Simulate sending one ps2 bit
     */

    task automatic send_bit (input logic b);
        begin
            ps2_data = b;
            #(PS2_BIT_PERIOD/2) ps2_clk = 1'b0;     //falling edge
            #(PS2_BIT_PERIOD/2) ps2_clk = 1'b1;     //Rising edge
        end
    endtask

    /**
     * Simulate sending a full ps2 scan code (11 bit)
     */

    task automatic send_scan_code (input [7:0] code);
        logic parity;
        begin
            parity = ~(^code);      //odd parity

            send_bit(1'b0);         //Start bit
            for (int i = 0; i < 8; i++) begin
                send_bit(code[i]);
            end
            send_bit(parity);       //parity bit
            send_bit(1'b1);         //Stop bit

            #(PS2_BIT_PERIOD);      //Inter byte delay   
        end
    endtask

    /**
     * Test a press and release sequence
     */

    task automatic test_key (input [7:0] code, input string name);
        begin
            $display("Testing Key: %s (0x%h)", name, code);

            //press
            send_scan_code(code);
            #(CLK_PERIOD * 20);

            case(name)
                "SPACE":    if (space) $display("PASS"); else $error("FAIL");
                "UP":       if (up) $display("PASS"); else $error("FAIL");
                "DOWN":     if (down) $display("PASS"); else $error("FAIL");
                "LEFT":     if (left) $display("PASS"); else $error("FAIL");
                "RIGHT":    if (right) $display("PASS"); else $error("FAIL");
                "TAB":      if (tab) $display("PASS"); else $error("FAIL");
            endcase
        end
    endtask

    /**
     * Assertions
     */

    //ensure ps2 clock is high when no data sent

    /**
     * Main test sequence
     */

    initial begin
        //wait for reset
        @(posedge rst_n);
        repeat (10) @(posedge clk);

        //run test cases
        test_key(8'h29, "SPACE");
        test_key(8'h75, "UP");
        test_key(8'h6B, "LEFT");
        test_key(8'h0D, "TAB");

        $display("All test completed");
        $finish;
    end
endmodule