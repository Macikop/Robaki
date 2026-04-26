/*
 * 
 * Designed by MP
 * How it works:
 * Data inserted form core and outputed by vga
 * 
 */

module draw_terrain(
    input logic clk,
    input logic rst_n,

    input logic data_in,
    input logic address[19:0],      //address = {addry[9:0], addrx[9:0]}
    input logic read_write,         //read - 0, write - 1

    input logic [11:0] color,

    vga_if.in vga_in,
    
    output logic data_out,

    vga_if.out vga_out
);

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals
     */
    
    (* ram_style = "block" *)
    logic terrain_buffer [0:1023][0:768];
    
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
        if (vga_in.vblnk || vga_in.hblnk) begin
            rgb_nxt = 12'h0_0_0;
        end else if (terrain_buffer[vga_in.hcount[9:0]][vga_in.vcount[9:0]] == 1'b1) begin
            rgb_nxt = color;
        end
        else begin
            rgb_nxt = vga_in.rgb;
        end
    end

endmodule