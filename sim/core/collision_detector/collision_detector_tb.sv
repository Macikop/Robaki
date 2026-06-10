/*
 * Designed by MP
 * 
 * Description:
 * Testbench for collision_detector module.
 */

module collision_detector_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;

    localparam WIDTH = 32;
    localparam HEIGHT = 32;
    localparam RAM_DELAY = 2;
    localparam TERRAIN_WIDTH = 1024;
    localparam TERRAIN_HEIGHT = 768;
    localparam ADDR_WIDTH = $clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT);

    /**
     * Local variables and signals
     */
    logic clk;
    logic rst_n;

    logic [10:0] pos_x;
    logic [10:0] pos_y;
    logic start_check;

    logic [7:0] collisions;
    logic done;

    // RAM Backend hardware wires
    logic [ADDR_WIDTH-1:0] ram_core_address;
    logic ram_core_clear;
    logic ram_core_data_out;

    /**
     * Interface Instantiations
     */
    // Create the interface array exactly matching the size the Mux expects
    memory_if mux_ports [0:2]();

    /**
     * Interconnect assignments for unused Mux slots
     */
    // Channel 0: Unused
    assign mux_ports[0].addresses = '0;
    assign mux_ports[0].request   = 1'b0;

    // Channel 2: Unused
    assign mux_ports[2].addresses = '0;
    assign mux_ports[2].request   = 1'b0;

    /**
     * Clock generation
     */
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

    /**
     * RAM Mux Wiring
     */

    ram_address_mux #(
        .ADDRESS_WIDTH(ADDR_WIDTH),
        .WORD_WIDTH(1),
        .INPUTS_NUMBER(3),
        .WRITE_CHANNEL(0),
        .RAM_DELAY(RAM_DELAY)
    ) u_ram_mux (
        .clk(clk),
        .rst_n(rst_n),
        .clients(mux_ports), // Pure interface array mapping
        .clear(1'b0),
        .ram_value(ram_core_data_out),
        .ram_address(ram_core_address),
        .ram_clear(ram_core_clear)
    );

    /**
     * Terrain RAM Placement
     */

    terrain_ram #(
        .WIDTH(TERRAIN_WIDTH),
        .HEIGHT(TERRAIN_HEIGHT),
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map1.dat")
    ) u_terrain_ram (
        .clk_vga(clk), 
        .clk_core(clk),
        .rst_n(rst_n),
        .address_vga('0),
        .address_core(ram_core_address),
        .clear(ram_core_clear),
        .data_out_vga(),
        .data_out_core(ram_core_data_out)
    );

    /**
     * DUT placement with Direct Interface Array Slice
     */

    collision_detector #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .RAM_DELAY(RAM_DELAY),
        .TERRAIN_WIDTH(TERRAIN_WIDTH),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .ram_client(mux_ports[1].out), // Directly mapping channel 1 out modport to the DUT
        .pos_x(pos_x),
        .pos_y(pos_y),
        .start_check(start_check),
        .collisions(collisions),
        .done(done)
    );


    /**
     * Tasks and functions
     */

    task automatic run_collision_test(
        input logic [10:0] x, 
        input logic [10:0] y
    );
        @(posedge clk);
        pos_x       = x;
        pos_y       = y;
        start_check = 1'b1;
        
        @(posedge clk);
        start_check = 1'b0;
        
        while (!done) begin
            @(posedge clk);
        end
        
        $display("Time: %t Check complete at (%0d, %0d). Collision Vector Result: %b", $time, x, y, collisions);
        @(posedge clk);
    endtask

    /**
     * Main test loop
     */
    initial begin
        pos_x       = '0;
        pos_y       = '0;
        start_check = 1'b0;

        @(negedge rst_n);
        @(posedge rst_n);

        $display("Open Place");
        run_collision_test(11'd100, 11'd200);

        $display("Partial Collision");
        run_collision_test(11'd619, 11'd360);

        $display("Complete collision");
        run_collision_test(11'd500, 11'd400);

        repeat (5) @(posedge clk);
        $finish;
    end

endmodule
