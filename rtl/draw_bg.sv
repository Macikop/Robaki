/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Draw background.
 */

module draw_bg (
        input  logic clk,
        input  logic rst_n,

        input  logic [10:0] vcount_in,
        input  logic        vsync_in,
        input  logic        vblnk_in,
        input  logic [10:0] hcount_in,
        input  logic        hsync_in,
        input  logic        hblnk_in,

        vga_if.out vga_out

        // output logic [10:0] vcount_out,
        // output logic        vsync_out,
        // output logic        vblnk_out,
        // output logic [10:0] hcount_out,
        // output logic        hsync_out,
        // output logic        hblnk_out,

        // output logic [11:0] rgb_out
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
            if (vcount_in == 0)                     // - top edge:
                rgb_nxt = 12'hf_f_0;                // - - make a yellow line.
            else if (vcount_in == VER_PIXELS - 1)   // - bottom edge:
                rgb_nxt = 12'hf_0_0;                // - - make a red line.
            else if (hcount_in == 0)                // - left edge:
                rgb_nxt = 12'h0_f_0;                // - - make a green line.
            else if (hcount_in == HOR_PIXELS - 1)   // - right edge:
                rgb_nxt = 12'h0_0_f;                // - - make a blue line.

            
                //letter K
            //vertical line
            else if ((vcount_in >= 200) && (vcount_in <= 500) && (hcount_in >= 100) && (hcount_in <= 130))
                rgb_nxt = 12'hf_0_0;

            //lower diagonal line
            else if ((vcount_in >= 350) && (vcount_in >= (hcount_in + 220)) && ((vcount_in <= 500) && (vcount_in <= (hcount_in + 260))) && (hcount_in >= 100))
                rgb_nxt = 12'hf_0_0;

            //upper diagonal line
                else if ((vcount_in >= 200) && (vcount_in >= (440 - hcount_in)) && ((vcount_in <= 350) && (vcount_in <= (480 - hcount_in))) && (hcount_in >= 100))
                rgb_nxt = 12'hf_0_0;


                //letter S
            //upper 3/4 of the circle of letter S
            else if (((((vcount_in - 300) ** 2) + ((hcount_in - 375) ** 2)) <= (75 ** 2)) && ((((vcount_in - 300) ** 2) + ((hcount_in - 375) ** 2)) >= (50 ** 2)) && !((vcount_in > 300) && (hcount_in > 375)))
                rgb_nxt = 12'h0_f_0;

            //lower part of letter S
            else if (((((vcount_in - 425) ** 2) + ((hcount_in - 375) ** 2)) <= (75 ** 2)) && ((((vcount_in - 425) ** 2) + ((hcount_in - 375) ** 2)) >= (50 ** 2)) && !((vcount_in < 425) && (hcount_in < 375)))
                rgb_nxt = 12'h0_f_0;


                //letter M
            //two vertial lines
            else if ((hcount_in >= 480) && (hcount_in <= 510) && (vcount_in >= 200) && (vcount_in <= 500))
                rgb_nxt = 12'h8_0_8;
            else if ((hcount_in >= 620) && (hcount_in <= 650) && (vcount_in >= 200) && (vcount_in <= 500))
                rgb_nxt = 12'h8_0_8;

            //two diagonal lines
            else if ((vcount_in >= 200) && (vcount_in <= 340) && (vcount_in >= (2*hcount_in - 820)) && (vcount_in <= (2*hcount_in - 760)))
                rgb_nxt = 12'h8_0_8;
            else if ((vcount_in >= 200) && (vcount_in <= 340) && (vcount_in >= (1440 - 2*hcount_in)) && (vcount_in <= (1500 - 2*hcount_in)))
                rgb_nxt = 12'h8_0_8;
            
            
                //letter P
            else if ((vcount_in <= 500) && (vcount_in >= 200) && (hcount_in >= 675) && (hcount_in <= 700))
                rgb_nxt = 12'h0_0_f;
            else if (((((vcount_in - 280) ** 2) + ((hcount_in - 700) ** 2)) <= (80 ** 2)) && ((((vcount_in - 280) ** 2) + ((hcount_in - 700) ** 2)) >= (55 ** 2)) && !(hcount_in < 700))
                rgb_nxt = 12'h0_0_f;

            else                                    // The rest of active display pixels:
                rgb_nxt = 12'h8_8_8;                // - fill with gray.
        end
    end

endmodule
