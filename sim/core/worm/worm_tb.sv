/*
 * Designed by MP
 * 
 * Description:
 * Testbench for worm module.
 */

module worm_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;
    localparam TERRAIN_WIDTH = 1024;
    localparam TERRAIN_HEIGHT = 768;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    logic sync;

    logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] ram_address;
    logic ram_clear;
    logic ram_data;

    memory_if clients[0:1]();

    logic active_turn;
    logic walking_en;
    logic explosion_en;
    logic left;
    logic right;
    logic [7:0] wind;
    logic [10:0] explosion_x;
    logic [10:0] explosion_y;
    logic [7:0] explosion_radius;
    logic explosion_done;
    logic [10:0] pos_x;
    logic [10:0] pos_y;
    logic direction;
    logic [6:0] worm_hp;
    logic worm_hit;

    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    /**
     * Sync generation
     */

    initial begin
        sync = 1'b0;
        forever begin
            repeat (9999) @(posedge clk);
            sync = 1'b1;
            @(posedge clk);
            sync = 1'b0;
        end
    end

    /**
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /*
     * Supporting modules
     */

    terrain_ram #(
        .WIDTH             (TERRAIN_WIDTH),
        .HEIGHT            (TERRAIN_HEIGHT),
        .TERRAIN_FILE_PATH ("../../rtl/vga_driver/maps/map1.dat")
    ) u_terrain_ram (
        .clk_vga       (1'b0),
        .clk_core      (clk),
        .rst_n         (rst_n),
        .address_vga   (20'b0),
        .address_core  (ram_address),
        .clear         (ram_clear),
        .data_out_vga  (),
        .data_out_core (ram_data)
    );

    ram_address_mux #(
        .ADDRESS_WIDTH (20),
        .WORD_WIDTH    (1),
        .INPUTS_NUMBER (2),
        .WRITE_CHANNEL (0),
        .RAM_DELAY     (2)
    ) u_ram_address_mux (
        .clk,
        .rst_n,
        .clients     (clients),
        .clear       (1'b0),
        .ram_value   (ram_data),
        .ram_address (ram_address),
        .ram_clear   (ram_clear)
    );

    /**
     * Dut placement
     */

    worm #(
        .WORM_WIDTH     (32),
        .WORM_HEIGHT    (32),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .GRAVITY        (10),
        .RAM_DELAY      (2),
        .INIT_X         (11'd100),
        .INIT_Y         (11'd100)
    ) u_worm (
        .clk,
        .rst_n,
        .active_turn      (active_turn),
        .sync,
        .explosion_x      (explosion_x),
        .explosion_y      (explosion_y),
        .explosion_radius (explosion_radius),
        .walking_en       (walking_en),
        .explosion_en     (explosion_en),
        .left             (left),
        .right            (right),
        .wind             (wind),
        .physics_ram      (clients[0]),
        .walk_ram         (clients[1]),
        .explosion_done   (explosion_done),
        .pos_x            (pos_x),
        .pos_y            (pos_y),
        .direction        (direction),
        .worm_hp          (worm_hp),
        .worm_hit         (worm_hit)
    );

    /**
     * Tasks and functions
     */

    task automatic init_inputs ();
        active_turn = 1'b0;
        explosion_x = 11'd0;
        explosion_y = 11'd0;
        explosion_radius = '0;
        walking_en = '0;
        explosion_en = '0;
        left = '0;
        right = '0;
        wind = '0;
    endtask

    task automatic walk (input logic dir, input int duration);
        active_turn = 1'b1;
        walking_en = 1'b1;
        right = dir;
        left = ~dir;

        repeat (duration) @(posedge sync);

    endtask

    task automatic explosion ();
        explosion_x = 11'd210;
        explosion_y = 11'd250;
        explosion_radius = 8'd25;
        explosion_en = 1'b1;

        @(posedge explosion_done);
        
    endtask 

    /**
     * Main test
     */

    initial begin

        @(negedge rst_n);
        @(posedge rst_n);

        init_inputs();

        repeat (2) @(posedge sync);

        walk(1'b1, 100);
        walk(1'b0, 50);

        init_inputs();

        explosion();

        repeat (10) @(posedge sync);
        $finish;
    end

endmodule

