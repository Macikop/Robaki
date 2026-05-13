/*
 * Designed by KS
 * How it works:
 * Verifies that serial to parallel conversion works
 * and that done pulse triggers exactly after 11th bit
 */

module ps2_interface_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 10.00;    //100MHz
    localparam RST_START_TIME = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;
    
    /**
     *  Signals
     */
    
    
    logic clk, rst_n, ps2_clk, ps2_data;
    logic [7:0] scan_code;
    logic done;

    ps2_interface dut (
        .clk(clk),
        .rst_n(rst_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .key_code(scan_code),
        .done(done)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    task send_bit(input bit b);
        begin
            ps2_data = b;
            repeat(20000) @(posedge clk); ps2_clk = 0;
            repeat(20000) @(posedge clk); ps2_clk = 1;
        end
    endtask

    task send_byte(input [7:0] data);
        begin
            send_bit(0);
            repeat(8) begin
                send_bit(data[0]);
                data = data >> 1;
            end
            send_bit(~(^data));
            send_bit(1);
            repeat(10000) @(posedge clk);
        end
    endtask

    initial begin 
        rst_n = 0; ps2_clk = 1; ps2_data = 1;
        repeat(100) @(posedge clk); rst_n = 1;

        $display("Testing scan code 0x1C");
        send_byte(8'h1c);
        //@(negedge done);
        if (scan_code == 8'h1c) $display("SUCCESS: received 0x1C");

        $display("Testing scan code 0x29");
        send_byte(8'h29);
        //@(negedge done);
        if (scan_code == 8'h29) $display("SUCCESS: received 0x29");

        $display("Testing scan code 0x0D");
        send_byte(8'h0d);
        //@(negedge done);
        if (scan_code == 8'h0d) $display("SUCCESS: received 0x0D");

        $display("Testing scan code 0x6B");
        send_byte(8'h6b);
        //@(negedge done);
        if (scan_code == 8'h6b) $display("SUCCESS: received 0x6B");

        

        repeat(1000) @(posedge clk);
        $finish;
    end

endmodule