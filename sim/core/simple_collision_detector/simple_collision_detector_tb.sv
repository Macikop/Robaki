/*
 * Designed by MP
 * 
 * Description:
 * Completed Testbench for simple_collision_detector with tests refactored as tasks.
 */

module simple_collision_detector_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam int WIDTH  = 4;
    localparam int HEIGHT = 4;
    localparam int RAM_DELAY = 2;

    /**
     * Local variables and signals
     */
    logic clk;
    logic rst_n;

    logic [$clog2(WIDTH * HEIGHT)-1:0] address_core;
    logic data_out_core; 
    logic clear_sig;

    memory_if client_ifs[0:0]();

    logic [10:0] pos_x;
    logic [10:0] pos_y;
    logic start;
    logic collision;
    logic done;

    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    /**
     * Reset generation block
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /**
     * Supporting modules instantiation
     */

    terrain_ram #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map_test.dat")
    ) u_terrain_ram (
        .clk_vga(1'b0),
        .clk_core(clk),
        .rst_n(rst_n),
        .address_vga(4'b0),
        .address_core(address_core),
        .clear(clear_sig),
        .data_out_vga(),
        .data_out_core(data_out_core)
    );

    ram_address_mux #(
        .ADDRESS_WIDTH ($clog2(WIDTH * HEIGHT)),
        .WORD_WIDTH    (1),
        .INPUTS_NUMBER (1), 
        .WRITE_CHANNEL (0),
        .RAM_DELAY     (RAM_DELAY)
    ) u_ram_mux (
        .clk(clk),
        .rst_n(rst_n),
        .clients(client_ifs), // Pass the interface collection directly
        .clear(1'b0),
        .ram_value(data_out_core),
        .ram_address(address_core),
        .ram_clear(clear_sig)
    );

    /**
     * DUT Placement
     */

    simple_collision_detector #(
        .RAM_DELAY(RAM_DELAY),
        .TERRAIN_WIDTH(WIDTH),
        .TERRAIN_HEIGHT(HEIGHT)
    ) u_collision_detector (
        .clk(clk),
        .rst_n(rst_n),
        .ram_client(client_ifs[0]), // Connected cleanly via the local interface index
        .pos_x(pos_x),
        .pos_y(pos_y),
        .start(start),
        .collision(collision),
        .done(done)
    );

    /**
     * Tasks and functions
     */

    task automatic run_collision_test(
        input logic [10:0] test_x,
        input logic [10:0] test_y,
        input logic expected_collision
    );
        begin
            @(posedge clk);
            pos_x = test_x;
            pos_y = test_y;
            start = 1'b1;
            
            @(posedge clk);
            start = 1'b0;

            @(posedge done);
            
            assert (collision === expected_collision) begin
                $display("PASSED (%0d, %0d) Match! Collision: %b", test_x, test_y, collision);
            end else begin
                $error("FAILED Mismatch at (%0d, %0d)! Got collision=%b, Expected=%b", test_x, test_y, collision, expected_collision);
            end
        end
    endtask

    /**
     * Main simulation execution sequence
     */

    initial begin
        start = 1'b0;
        pos_x = '0;
        pos_y = '0;

        @(negedge rst_n);
        @(posedge rst_n);
        
        run_collision_test(11'd0, 11'd0, 1'b0); /* Address 0  -> 0 */
        run_collision_test(11'd1, 11'd0, 1'b1); /* Address 1  -> 1 */
        run_collision_test(11'd2, 11'd0, 1'b1); /* Address 2  -> 1 */
        run_collision_test(11'd1, 11'd2, 1'b0); /* Address 9  -> 0 */
        run_collision_test(11'd2, 11'd2, 1'b1); /* Address 10 -> 1 */
        run_collision_test(11'd2, 11'd3, 1'b1); /* Address 14 -> 1 */
        run_collision_test(11'd3, 11'd3, 1'b0); /* Address 15 -> 0 */

        repeat (3) @(posedge clk);
        $display("Testbench finished");
        $finish;
    end

endmodule