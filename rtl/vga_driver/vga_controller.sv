/* Designed by MP
 * 
 * How it works:
 * gets data from one of the buffer and outputs it acording to VGA standard
 */

module vga_controller (
        input  logic clk,
        input  logic rst_n,

        input  logic [11:0] frame_buffer [0:1023] [0:767] [0:1];
        input  logic        current_buffer;

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
            rgb_nxt = frame_buffer[hcount_in][vcount_in][current_buffer];
        end
    end

endmodule
