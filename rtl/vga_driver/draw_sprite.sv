/*
 * Designed by MP
 *
 * How it works:
 * Draws sprite, modifies it according to flags
 */

module draw_sprite #(
    parameter WIDTH = 32,
    parameter HEIGHT = 32
)(
    input  logic clk,    
    input  logic rst_n,

    input  logic enable,

    input  logic [10:0] x_pos,
    input  logic [10:0] y_pos,

    input  logic [2:0] modifier,    /* [0] - transpose, [1] - flips X, [2] flips Y*/

    input  logic [12:0] rgb_pixel,
    output logic [$clog2(WIDTH*HEIGHT)-1:0] pixel_address,

    vga_if.in vga_in,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    /*
     * Local variables and signals
     */

    localparam X_BITS = $clog2(WIDTH);
    localparam Y_BITS = $clog2(HEIGHT);

    /*
     * Delay signals
     */
    
    logic [$clog2(WIDTH*HEIGHT)-1:0] pixel_address_nxt;

    logic [10:0] hcount_d, hcount_d2, vcount_d, vcount_d2;
    logic        hsync_d, hsync_d2, vsync_d, vsync_d2;
    logic        hblnk_d, hblnk_d2, vblnk_d, vblnk_d2;

    logic [11:0] rgb_nxt, rgb_d, rgb_d2;

    /*
     * Modifications signals
     */

    logic [10:0] dx, dy;

    logic [11:0] active_width, active_height;

    /*
     * Internal logic
     */

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hcount_d        <= '0;
            vcount_d        <= '0;
            hsync_d         <= '0;
            vsync_d         <= '0;
            hblnk_d         <= '0;
            vblnk_d         <= '0;
            rgb_d           <= '0;

            pixel_address    <= '0;

            hcount_d2       <= '0;
            vcount_d2       <= '0;
            hsync_d2        <= '0;
            vsync_d2        <= '0;
            hblnk_d2        <= '0;
            vblnk_d2        <= '0;
            rgb_d2          <= '0;

            vga_out.hcount  <= '0;
            vga_out.vcount  <= '0;
            vga_out.hsync   <= '0;
            vga_out.vsync   <= '0;
            vga_out.hblnk   <= '0;
            vga_out.vblnk   <= '0;
            vga_out.rgb     <= '0;
        end
        else begin
            // stage 1
            hcount_d        <= vga_in.hcount;
            vcount_d        <= vga_in.vcount;
            hsync_d         <= vga_in.hsync;
            vsync_d         <= vga_in.vsync;
            hblnk_d         <= vga_in.hblnk;
            vblnk_d         <= vga_in.vblnk;
            rgb_d           <= vga_in.rgb;

            pixel_address  <= pixel_address_nxt;

            hcount_d2       <= hcount_d;
            vcount_d2       <= vcount_d;
            hsync_d2        <= hsync_d;
            vsync_d2        <= vsync_d;
            hblnk_d2        <= hblnk_d;
            vblnk_d2        <= vblnk_d;
            rgb_d2          <= rgb_d;

            // stage 2
            vga_out.hcount  <= hcount_d2;
            vga_out.vcount  <= vcount_d2;
            vga_out.hsync   <= hsync_d2;
            vga_out.vsync   <= vsync_d2;
            vga_out.hblnk   <= hblnk_d2;
            vga_out.vblnk   <= vblnk_d2;
            vga_out.rgb     <= rgb_nxt;
        end
    end

    always_comb begin

        active_width  = (modifier[0]) ? HEIGHT[11:0] : WIDTH[11:0];
        active_height = (modifier[0]) ? WIDTH[11:0]  : HEIGHT[11:0];

        if ((vga_in.hcount >= x_pos) && (vga_in.hcount < x_pos + active_width) && (vga_in.vcount >= y_pos) && (vga_in.vcount < y_pos + active_height)) begin

            dx = vga_in.hcount - x_pos;
            dy = vga_in.vcount - y_pos;

            if (dx < active_width && dy < active_height) begin
                
                if (modifier[1] == 1'b1) begin
                    dx = (active_width - 1) - dx;
                end

                if (modifier[2] == 1'b1) begin
                    dy = (active_height - 1) - dy;
                end

                if (modifier[0] == 1'b1) begin
                    pixel_address_nxt = {dx[X_BITS-1:0], dy[Y_BITS-1:0]};
                end else begin
                    pixel_address_nxt = {dy[Y_BITS-1:0], dx[X_BITS-1:0]};
                end

            end else begin
                pixel_address_nxt = '0;
            end
            
        end else begin
            pixel_address_nxt = '0;
        end

        if (enable && ((hcount_d2 >= x_pos) && (hcount_d2 < x_pos + active_width) && (vcount_d2 >= y_pos) && (vcount_d2 < y_pos + active_height))) begin
            rgb_nxt = (rgb_pixel[12] == 1'b1) ? rgb_d2 : rgb_pixel[11:0];
        end else begin
            rgb_nxt = rgb_d2;
        end
    end

endmodule
