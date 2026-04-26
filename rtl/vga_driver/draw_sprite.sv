/*
 * Designed by MP
 *
 * Draws sprite rectangle
 */
module draw_sprite #(
    parameter WIDTH  = 48,
    parameter HEIGHT = 64
)(
    input logic clk,
    input logic rst_n,

    input logic [11:0] xpos,
    input logic [11:0] ypos,

    vga_if.in vga_in,

    input  logic [12:0] rgb_pixel,
    output logic [11:0] pixel_addres,

    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    logic [11:0] rgb_nxt, rgb_d;
    logic [11:0] pixel_addres_nxt;

    // pipeline registers
    logic [11:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d;
    logic        hblnk_d, vblnk_d;

    logic [11:0] dx, dy;

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

            pixel_addres    <= '0;

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

            pixel_addres  <= pixel_addres_nxt;

            // stage 2
            vga_out.hcount  <= hcount_d;
            vga_out.vcount  <= vcount_d;
            vga_out.hsync   <= hsync_d;
            vga_out.vsync   <= vsync_d;
            vga_out.hblnk   <= hblnk_d;
            vga_out.vblnk   <= vblnk_d;
            vga_out.rgb     <= rgb_nxt;
        end
    end

    /*
     * Combinational draw logic
     */
    always_comb begin

        if (hblnk_d || vblnk_d) begin
            rgb_d = 12'h000;
            pixel_addres_nxt = '0;
        end else if ((vga_in.hcount >= xpos) && (vga_in.hcount < xpos + WIDTH) && (vga_in.vcount >= ypos) && (vga_in.vcount < ypos + HEIGHT)) begin

            dx = vga_in.hcount - xpos + 1;
            dy = vga_in.vcount - ypos;

            pixel_addres_nxt = {dy[5:0], dx[5:0]};
            
            rgb_d = vga_in.rgb;

        end else begin
            pixel_addres_nxt = '0;
            rgb_d = vga_in.rgb;
        end

        if ((hcount_d >= xpos) && (hcount_d < xpos + WIDTH) && (vcount_d >= ypos) && (vcount_d < ypos + HEIGHT))begin
            if (rgb_pixel[12] == 1'b0) begin
                rgb_nxt = rgb_pixel [11:0];
            end else begin
                rgb_nxt = rgb_d;
            end
        end else begin
            rgb_nxt = rgb_d;
        end
        
        

    end

endmodule