/*
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
 * The project top module.
 */

module top_vga (
        input  logic clk_vga,
        input logic clk_core,
        input  logic rst_n,
        output logic vs,
        output logic hs,
        output logic [3:0] r,
        output logic [3:0] g,
        output logic [3:0] b
    );

    timeunit 1ns;
    timeprecision 1ps;

    /*
     * Local variables and signals
     */

    localparam SPRITE_WIDTH = 32;
    localparam SPRITE_HEIGHT = 32;

    localparam TERRAIN_WIDTH = 1024;
    localparam TERRAIN_HEIGHT = 768;
    
    // VGA signals from timing
    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;


    wire [12:0] rgb_sprite;
    wire [$clog2(SPRITE_WIDTH * SPRITE_HEIGHT)-1:0] address_sprite;

    wire terrain_present;
    wire [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] address_terrain;

    vga_if vga_bg();
    vga_if vga_terrain();
    vga_if vga_circle();
    vga_if vga_output();



    /*
     * Signals assignments
     */

    assign vs = vga_output.vsync;
    assign hs = vga_output.hsync;
    assign {r,g,b} = vga_output.rgb;


    /*
     * Submodules instances
     */

    vga_timing u_vga_timing (
        .clk(clk_vga),
        .rst_n,
        .vcount (vcount_tim),
        .vsync  (vsync_tim),
        .vblnk  (vblnk_tim),
        .hcount (hcount_tim),
        .hsync  (hsync_tim),
        .hblnk  (hblnk_tim)
    );

    draw_bg #(
        .COLOR(12'h0_a_a)
    ) u_draw_bg (
        .clk(clk_vga),
        .rst_n,

        .vcount_in  (vcount_tim),
        .vsync_in   (vsync_tim),
        .vblnk_in   (vblnk_tim),
        .hcount_in  (hcount_tim),
        .hsync_in   (hsync_tim),
        .hblnk_in   (hblnk_tim),

        .vga_out(vga_bg)

    );

    terrain_ram #(
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map1.dat"),
        .WIDTH(TERRAIN_WIDTH),
        .HEIGHT(TERRAIN_HEIGHT)
    ) u_terrain_ram (
        .clk_vga,
        .clk_core,
        .rst_n,

        .address(address_terrain),
        .data_out(terrain_present)
    );

    draw_terrain #(
        .TERRAIN_WIDTH(TERRAIN_WIDTH),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT),
        .X_OFFSET(0),
        .Y_OFFSET(0)
    ) u_draw_terrain (
        .clk(clk_vga),
        .rst_n,

        .color(12'h0_F_0),

        .data_in(terrain_present),
        .address(address_terrain),

        .vga_in(vga_bg),
        .vga_out(vga_terrain)
    );

    sprite_rom #(
        .SPRITE_PATH("../../rtl/vga_driver/sprite_bank/arrow.dat"),
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_sprite_rom (
        .clk(clk_vga),
        .rst_n,
        .address(address_sprite),
        .rgb(rgb_sprite)

    );

    draw_sprite #(
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_draw_sprite (
        .clk(clk_vga),
        .rst_n,
        
        .x_pos(12'd100),
        .y_pos(12'd100),
        .vga_in(vga_terrain),

        .modifier(3'b000),

        .rgb_pixel(rgb_sprite),
        .pixel_address(address_sprite),

        .vga_out(vga_circle)
    );

    draw_circle u_draw_circle(
        .clk(clk_vga),
        .rst_n,
        
        .x_pos(12'd30),
        .y_pos(12'd30),

        .radius(12'd25),
        .color(12'hF_F_0),

        .vga_in(vga_circle),
        .vga_out(vga_output)
    );

endmodule
