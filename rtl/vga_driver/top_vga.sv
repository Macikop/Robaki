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

module top_vga #(
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768,
    parameter SPRITE_WIDTH = 32,
    parameter SPRITE_HEIGHT = 32
)(
    input  logic clk,
    input  logic rst_n,

    input  logic start_screen_en,
    input  logic draw_worms,
    input  logic end_screen_en,

    input  logic [10:0] draw_worm_0_x_pos,
    input  logic [10:0] draw_worm_0_y_pos,
    input  logic        draw_worm_0_orientation,
    input  logic [10:0] draw_worm_1_x_pos,
    input  logic [10:0] draw_worm_1_y_pos,
    input  logic        draw_worm_1_orientation,

    input  logic [10:0] aim_x_pos,
    input  logic [10:0] aim_y_pos,
    input  logic        aim_en,

    input  logic [10:0] draw_bullet_x,
    input  logic [10:0] draw_bullet_y,
    input  logic        draw_bullet_en,

    input  logic [10:0] draw_explosion_x,
    input  logic [10:0] draw_expolsion_y,
    input  logic [10:0] draw_explosion_radius,
    input  logic        draw_explosion_en,
    input  logic [11:0] draw_explosion_color,


    input  logic terrain_present,
    output logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] address_terrain,
    
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

    localparam LOGO_WIDTH = 256;
    localparam LOGO_HEIGHT = 128;
    
    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    logic [10:0] circle_x_pos;
    logic [10:0] circle_y_pos;
    logic [10:0] circle_radius;
    logic [11:0] circle_color;

    wire [12:0] logo_rgb;
    wire [$clog2(LOGO_WIDTH * LOGO_HEIGHT)-1:0] logo_address;

    wire [12:0] worm0_rgb;
    wire [$clog2(SPRITE_WIDTH * SPRITE_HEIGHT)-1:0] worm0_address;

    wire [12:0] worm1_rgb;
    wire [$clog2(SPRITE_WIDTH * SPRITE_HEIGHT)-1:0] worm1_address;

    wire [12:0] aim_rgb;
    wire [$clog2(SPRITE_WIDTH * SPRITE_HEIGHT)-1:0] aim_address;

    vga_if vga_bg();
    vga_if vga_terrain();
    vga_if vga_logo();
    vga_if vga_worm0();
    vga_if vga_worm1();
    vga_if vga_aim();
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
        .clk,
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
        .clk,
        .rst_n,

        .vcount_in  (vcount_tim),
        .vsync_in   (vsync_tim),
        .vblnk_in   (vblnk_tim),
        .hcount_in  (hcount_tim),
        .hsync_in   (hsync_tim),
        .hblnk_in   (hblnk_tim),

        .vga_out(vga_bg)

    );

    draw_terrain #(
        .TERRAIN_WIDTH(TERRAIN_WIDTH),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT),
        .X_OFFSET(0),
        .Y_OFFSET(0)
    ) u_draw_terrain (
        .clk,
        .rst_n,
        .enable(1'b1),

        .color(12'h0_F_0),

        .data_in(terrain_present),
        .address(address_terrain),

        .vga_in(vga_bg),
        .vga_out(vga_terrain)
    );

    sprite_rom #(
        .SPRITE_PATH("../../rtl/vga_driver/sprite_bank/logo.dat"),
        .WIDTH(LOGO_WIDTH),
        .HEIGHT(LOGO_HEIGHT)
    ) u_logo_rom (
        .clk,
        .rst_n,
        .address(logo_address),
        .rgb(logo_rgb)

    );

    draw_sprite #(
        .WIDTH(LOGO_WIDTH),
        .HEIGHT(LOGO_HEIGHT)
    ) u_draw_logo (
        .clk,
        .rst_n,
        .enable(start_screen_en),
        
        .x_pos(11'd384),
        .y_pos(11'd320),
        .vga_in(vga_terrain),

        .modifier(3'b000),

        .rgb_pixel(logo_rgb),
        .pixel_address(logo_address),

        .vga_out(vga_logo)
    );

    sprite_rom #(
        .SPRITE_PATH("../../rtl/vga_driver/sprite_bank/worm.dat"),
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_worm0_rom (
        .clk,
        .rst_n,
        .address(worm0_address),
        .rgb(worm0_rgb)

    );

    draw_sprite #(
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_draw_worm0 (
        .clk,
        .rst_n,
        .enable(draw_worms),
        
        .x_pos(draw_worm_0_x_pos),
        .y_pos(draw_worm_0_y_pos),
        .vga_in(vga_logo),

        .modifier({1'b0, draw_worm_0_orientation, 1'b0}),

        .rgb_pixel(worm0_rgb),
        .pixel_address(worm0_address),

        .vga_out(vga_worm0)
    );

    sprite_rom #(
        .SPRITE_PATH("../../rtl/vga_driver/sprite_bank/worm.dat"),
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_worm1_rom (
        .clk,
        .rst_n,
        .address(worm1_address),
        .rgb(worm1_rgb)

    );

    draw_sprite #(
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_draw_worm1 (
        .clk,
        .rst_n,
        .enable(draw_worms),
        
        .x_pos(draw_worm_1_x_pos),
        .y_pos(draw_worm_1_y_pos),
        .vga_in(vga_worm0),

        .modifier({1'b0, draw_worm_1_orientation, 1'b0}),

        .rgb_pixel(worm1_rgb),
        .pixel_address(worm1_address),

        .vga_out(vga_worm1)
    );

    sprite_rom #(
        .SPRITE_PATH("../../rtl/vga_driver/sprite_bank/aim.dat"),
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_aim_rom (
        .clk,
        .rst_n,
        .address(aim_address),
        .rgb(aim_rgb)

    );

    draw_sprite #(
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_draw_aim (
        .clk,
        .rst_n,
        .enable(aim_en),
        
        .x_pos(aim_x_pos),
        .y_pos(aim_y_pos),
        .vga_in(vga_worm1),

        .modifier(3'b000),

        .rgb_pixel(aim_rgb),
        .pixel_address(aim_address),

        .vga_out(vga_aim)
    );

    always_comb begin
        if(draw_explosion_en) begin
            circle_x_pos = draw_explosion_x;
            circle_y_pos = draw_expolsion_y;
            circle_radius = draw_explosion_radius;
            circle_color = draw_explosion_color;
        end else if (draw_bullet_en) begin
            circle_x_pos = draw_bullet_x;
            circle_y_pos = draw_bullet_y;
            circle_radius = 11'd10;
            circle_color = 12'h0_0_0;
        end else begin
            circle_x_pos = '0;
            circle_y_pos = '0;
            circle_radius = '0;
            circle_color = 12'h0_0_0;
        end
    end

    draw_circle u_draw_circle(
        .clk,
        .rst_n,
        .enable(draw_explosion_en || draw_bullet_en),
        
        .x_pos(circle_x_pos),
        .y_pos(circle_y_pos),

        .radius(circle_radius),
        .color(circle_color),

        .vga_in(vga_aim),
        .vga_out(vga_output)
    );

endmodule
