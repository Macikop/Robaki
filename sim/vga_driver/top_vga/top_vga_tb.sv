/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Testbench for top_vga.
 * Thanks to the tiff_writer module, an expected image
 * produced by the project is exported to a tif file.
 * Since the vs signal is connected to the go input of
 * the tiff_writer, the first (top-left) pixel of the tif
 * will not correspond to the vga project (0,0) pixel.
 * The active image (not blanked space) in the tif file
 * will be shifted down by the number of lines equal to
 * the difference between VER_SYNC_START and VER_TOTAL_TIME.
 */

module top_vga_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.3846;     // 65 MHz
    localparam RST_START_TIME = 30;
    localparam RST_ACTIVE_TIME = 30;

    localparam TERRAIN_WIDTH = 1024;
    localparam TERRAIN_HEIGHT = 768;

    /**
     * Local variables and signals
     */

    logic clk, rst_n;
    wire vs, hs;
    wire [3:0] r, g, b;

    logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] address_terrain;
    logic terrain_value;



    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Submodules instances
     */

    terrain_ram #(
        .WIDTH             (TERRAIN_WIDTH),
        .HEIGHT            (TERRAIN_HEIGHT),
        .TERRAIN_FILE_PATH ("../../rtl/vga_driver/maps/map1.dat")
    ) u_terrain_ram (
        .clk_vga       (clk),
        .clk_core      (1'b0),
        .rst_n,
        .address_vga   (address_terrain),
        .address_core  (20'b0),
        .clear         (1'b0),
        .data_out_vga  (terrain_value),
        .data_out_core ()
    );

    top_vga #(
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .SPRITE_WIDTH   (32),
        .SPRITE_HEIGHT  (32)
    ) dut (
        .clk,
        .rst_n,
        .start_screen_en         (1'b1),
        .draw_worms              (1'b1),
        .end_screen_en           (1'b1),
        .draw_worm_0_x_pos       (11'd100),
        .draw_worm_0_y_pos       (11'd100),
        .draw_worm_0_orientation (1'b1),
        .draw_worm_1_x_pos       (11'd200),
        .draw_worm_1_y_pos       (11'd200),
        .draw_worm_1_orientation (1'b0),
        .aim_x_pos               (11'd300),
        .aim_y_pos               (11'd300),
        .aim_en                  (1'b1),
        .draw_bullet_x           (11'd100),
        .draw_bullet_y           (11'd200),
        .draw_bullet_en          (1'b1),
        .draw_explosion_x        (11'd200),
        .draw_expolsion_y        (11'd100),
        .draw_explosion_radius   (11'd50),
        .draw_explosion_en       (1'b0),
        .draw_explosion_color    (12'hF_0_0),
        .terrain_present         (terrain_value),
        .address_terrain         (address_terrain),
        .vs                      (vs),
        .hs                      (hs),
        .r                       (r),
        .g                       (g),
        .b                       (b)
    );

    tiff_writer #(
        .XDIM(16'd1344),
        .YDIM(16'd806),
        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk),
        .r({r,r}), // fabricate an 8-bit value
        .g({g,g}), // fabricate an 8-bit value
        .b({b,b}), // fabricate an 8-bit value
        .go(vs)
    );


    /**
     * Main test
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;

        $display("If simulation ends before the testbench");
        $display("completes, use the menu option to run all.");
        $display("Prepare to wait a long time...");

        wait (vs == 1'b0);
        @(negedge vs) $display("Info: negedge VS at %t",$time);
        @(negedge vs) $display("Info: negedge VS at %t",$time);

        // End the simulation.
        $display("Simulation is over, check the waveforms.");
        $finish;
    end

endmodule
