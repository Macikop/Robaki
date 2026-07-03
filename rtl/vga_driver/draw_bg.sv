/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg #(
    parameter [11:0] COLOR = 12'h0_a_a
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [10:0] vcount_in,
    input  logic        vsync_in,
    input  logic        vblnk_in,
    input  logic [10:0] hcount_in,
    input  logic        hsync_in,
    input  logic        hblnk_in,

    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;


    /**
     * Internal logic
     */

    always_ff @(posedge clk or negedge rst_n) begin : bg_ff_blk
        if (!rst_n) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.vcount <= vcount_in;
            vga_out.vsync  <= vsync_in;
            vga_out.vblnk  <= vblnk_in;
            vga_out.hcount <= hcount_in;
            vga_out.hsync  <= hsync_in;
            vga_out.hblnk  <= hblnk_in;
            vga_out.rgb    <= rgb_nxt;
        end
    end

    always_comb begin : bg_comb_blk
        if (vblnk_in || hblnk_in) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else begin                              // Active region:
            // if (vcount_in == 0)                     // - top edge:
            //     rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            // else if (vcount_in == VER_PIXELS - 1)   // - bottom edge:
            //     rgb_nxt = 12'hf_0_0;                // - - make a red line.
            // else if (hcount_in == 0)                // - left edge:
            //     rgb_nxt = 12'h0_f_0;                // - - make a green line.
            // else if (hcount_in == HOR_PIXELS - 1)   // - right edge:
            //     rgb_nxt = 12'h0_0_f;                // - - make a blue line.

            rgb_nxt = COLOR;
        end
    end

endmodule
