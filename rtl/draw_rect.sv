module draw_rect #(
    parameter X = 100,
    parameter Y = 100,
    parameter WIDTH = 300,
    parameter HIGHT = 50,
    parameter [11:0] COLOR = 12'hf_f_f 
)(

    input logic clk,
    input logic rst_n,

    vga_if.in vga_in,
    vga_if.out vga_out
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;


    /**
     * Internal logic
     */

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            vga_out.vcount <= '0;
            vga_out.vsync  <= '0;
            vga_out.vblnk  <= '0;
            vga_out.hcount <= '0;
            vga_out.hsync  <= '0;
            vga_out.hblnk  <= '0;
            vga_out.rgb    <= '0;
        end else begin
            vga_out.vcount <= vga_in.vcount;
            vga_out.vsync  <= vga_in.vsync;
            vga_out.vblnk  <= vga_in.vblnk;
            vga_out.hcount <= vga_in.hcount;
            vga_out.hsync  <= vga_in.hsync;
            vga_out.hblnk  <= vga_in.hblnk;
            vga_out.rgb    <= rgb_nxt;
        end
    end


    always_comb begin
        if (vga_in.vblnk || vga_in.hblnk) begin             // Blanking region:
            rgb_nxt = 12'h0_0_0;                    // - make it it black.
        end else if ((vga_in.hcount >= X) && (vga_in.hcount <= (X + WIDTH)) && (vga_in.vcount >= Y) && (vga_in.vcount <= (Y + HIGHT))) begin
                rgb_nxt = COLOR;
        end
        else begin
            rgb_nxt = vga_in.rgb;
        end
    end

endmodule