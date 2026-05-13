

module key_decoder_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 10.0;  //100MHz
    localparam RST_START_TIME = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;
    
    /**
     *  Signals
     */
    
    
    logic clk, rst_n, done;
    logic [7:0] scan_code;
    logic up, down, left, right, space, tab;

    key_decoder dut(
        .clk(clk),
        .rst_n(rst_n),
        .key_code(scan_code),
        .done(done),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .space(space),
        .tab(tab)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    task drive_code (input [7:0] code);
        begin
            @(posedge clk);
            scan_code = code;
            done = 1;
            @(posedge clk)
            done = 0;
            repeat(20) @(posedge clk);
        end
    endtask

    initial begin

        rst_n = 0;
        done = 0;
        scan_code = 0;
        repeat(100) @(posedge clk);
        rst_n = 1;

        $display("Simulating Space Press (0x29)");
        drive_code(8'h29);
        repeat(10) @(posedge clk);
        if (space) $display("Space signal is HIGH");

        $display("Simulating Space release (0xF0, 0x29)");
        drive_code(8'hf0);
        drive_code(8'h29);
        repeat(10) @(posedge clk);

        if (!space) $display("Space signal is LOW");

        $display("Simulating Up Arrow (0x75)");
        drive_code(8'h75);
        repeat(10) @(posedge clk);
        if (up) $display("Up signal is HIGH");

        repeat(100) @(posedge clk);
        $finish;
    end

endmodule
    