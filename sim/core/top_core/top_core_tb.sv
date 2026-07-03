/*
 * Designed by MP
 * 
 * Description:
 * Testbench for top_core module.
 */

module top_core_tb;

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
    logic vsync;
    

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

    /*
     * Vsync generation
     */

    initial begin
        vsync = 1'b0;
        forever begin
            repeat (9999) @(posedge clk);
            vsync = 1'b1;
            @(posedge clk);
            vsync = 1'b0;
        end
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
        .address_core  (),
        .clear         (),
        .data_out_vga  (),
        .data_out_core ()
    );


    /**
     * Dut placement
     */
    
    top_core #(
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .WORM_WIDTH     (32),
        .WORM_HEIGHT    (32),
        .GRAVITY        (10)
    ) dut (
        .clk,
        .rst_n,
        .vsync,
        .space                   (),
        .up                      (),
        .down                    (),
        .left                    (),
        .right                   (),
        .ram_value               (),
        .ram_address             (),
        .ram_clear               (),
        .draw_worms              (),
        .draw_worm_0_x_pos       (),
        .draw_worm_0_y_pos       (),
        .draw_worm_0_orientation (),
        .draw_worm_1_x_pos       (),
        .draw_worm_1_y_pos       (),
        .draw_worm_1_orientation (),
        .aim_x_pos               (),
        .aim_y_pos               (),
        .aim_en                  (),
        .draw_bullet_x           (),
        .draw_bullet_y           (),
        .draw_bullet_en          (),
        .draw_explosion_x        (),
        .draw_explosion_y        (),
        .draw_explosion_radius   (),
        .draw_explosion_en       (),
        .draw_explosion_color    (),
        .draw_logo               (),
        .draw_end                ()   
    );


    /**
     * Tasks and functions
     */


    /**
     * Assertions
     */


    /**
     * Main test
     */

    initial begin

        @(negedge rst_n);
        @(posedge rst_n);

        repeat (10000) @(posedge vsync);

        $finish;
    end

endmodule
