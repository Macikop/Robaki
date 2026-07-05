module draw_circle (
    input logic clk,
    input logic rst_n,

    input logic enable,

    input logic [10:0] x_pos,
    input logic [10:0] y_pos,

    input logic [10:0] radius,
    input logic [11:0] color,

    vga_if.in vga_in,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;

    logic [10:0] dx, dy;
    logic [10:0] max_d, min_d;
    logic [11:0] approx_r;


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
        approx_r = '0;

        if(enable) begin
            dx = (vga_in.hcount > x_pos) ? (vga_in.hcount - x_pos) : (x_pos - vga_in.hcount);
            dy = (vga_in.vcount > y_pos) ? (vga_in.vcount - y_pos) : (y_pos - vga_in.vcount);

            max_d = (dx > dy) ? dx : dy;
            min_d = (dx > dy) ? dy : dx;

            /*
             * approx_r = max + 3/8 * min
             * 3/8 = 1/4 + 1/8
             */

            approx_r = max_d + (min_d >> 2) + (min_d >> 3);
        end

        if (vga_in.vblnk || vga_in.hblnk) begin
                rgb_nxt = 12'h0_0_0;
        end else if (enable) begin
            if (approx_r < radius) begin
                rgb_nxt = color;
            end else begin
                rgb_nxt = vga_in.rgb;
            end
        end else begin
            rgb_nxt = vga_in.rgb;
        end
    end

endmodule
