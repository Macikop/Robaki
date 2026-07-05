/*
 * Designed by MP
 *
 * How it works:
 * Draws terrain from ram, ram is driven by core
 */

module draw_terrain #(
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768,

    parameter X_OFFSET = 0,
    parameter Y_OFFSET = 0
)(
    input  logic clk,
    input  logic rst_n,

    input  logic enable,

    input  logic [11:0] color,

    input  logic data_in,
    output logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] address,      //address = {addry[YBITS-1:0], addrx[X_BITS-1:0]}

    vga_if.in vga_in,
    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    /*
     * Local variables and signals
     */

    localparam X_BITS = $clog2(TERRAIN_WIDTH);
    localparam Y_BITS = $clog2(TERRAIN_HEIGHT);
    
    logic [11:0] rgb_nxt;

    logic [10:0] hcount_d, vcount_d;
    logic        hsync_d, vsync_d;
    logic        hblnk_d, vblnk_d;
    logic [11:0] rgb_d;

    logic [10:0] dx, dy;
    logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] address_nxt;

    delay #(
        .WIDTH(38),
        .CLK_DEL(2)
    ) u_vga_delay (
        .clk(clk),
        .rst_n(rst_n),
        .din({vga_in.hcount, vga_in.vcount, vga_in.hsync, vga_in.vsync, vga_in.hblnk, vga_in.vblnk, vga_in.rgb}),
        .dout({hcount_d, vcount_d, hsync_d, vsync_d, hblnk_d, vblnk_d, rgb_d})
    );

    /*
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
            address        <= '0;

        end else begin

            address        <= address_nxt;

            vga_out.hcount <= hcount_d;
            vga_out.vcount <= vcount_d;
            vga_out.hsync  <= hsync_d;
            vga_out.vsync  <= vsync_d;
            vga_out.hblnk  <= hblnk_d;
            vga_out.vblnk  <= vblnk_d;
            vga_out.rgb    <= rgb_nxt;

        end
    end


    always_comb begin
        if ((vga_in.hcount >= X_OFFSET) && (vga_in.hcount < X_OFFSET + TERRAIN_WIDTH) && (vga_in.vcount >= Y_OFFSET) && (vga_in.vcount < Y_OFFSET + TERRAIN_HEIGHT)) begin
            
            dx = vga_in.hcount - X_OFFSET;
            dy = vga_in.vcount - Y_OFFSET;

            //address_nxt = {dy[Y_BITS-1:0], dx[X_BITS-1:0]};
            address_nxt = dy * TERRAIN_WIDTH + dx;

        end else begin
            address_nxt = '0;
        end
            
        if (enable && ((hcount_d >= X_OFFSET) && (hcount_d < X_OFFSET + TERRAIN_WIDTH) && (vcount_d >= Y_OFFSET) && (vcount_d < Y_OFFSET + TERRAIN_HEIGHT))) begin
            rgb_nxt = data_in ? color : rgb_d;
        end else begin
            rgb_nxt = rgb_d;
        end

    end

endmodule