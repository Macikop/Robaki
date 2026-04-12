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
 * The project top module.
 */

module top_vga (
        input  logic clk,
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

    // VGA signals from timing
    wire [10:0] vcount_tim, hcount_tim;
    wire vsync_tim, hsync_tim;
    wire vblnk_tim, hblnk_tim;

    // VGA signals from background
    // wire [10:0] vcount_bg, hcount_bg;
    // wire vsync_bg, hsync_bg;
    // wire vblnk_bg, hblnk_bg;
    // wire [11:0] rgb_bg;

    vga_if vga_bg();
    vga_if vga_rect();


    /**
     * Signals assignments
     */

    assign vs = vga_rect.vsync;
    assign hs = vga_rect.hsync;
    assign {r,g,b} = vga_rect.rgb;


    /**
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

    draw_bg u_draw_bg (
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

    draw_rect u_draw_rect(
        .clk,
        .rst_n,
        .vga_in(vga_bg),
        .vga_out(vga_rect)
    );

endmodule
