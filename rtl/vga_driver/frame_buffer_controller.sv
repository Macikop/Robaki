/* Designed by MP
 * 
 * How it works:
 * frame data gets send to one buffer and vga reads from other, for next frame buffers swaps
 */

module frame_buffer_controller(

    input  logic rst_n,             //nie wiem czy nie powinny być dwa resety dla dwóch róznych zegarów

    input  logic clk_core,
    output logic send_new_frame,
    igb_if.in igb_in,
    
    
    input  logic clk_vga
    vga_if.out vga_out;
);

    timeunit 1ns;
    timeprecision 1ps;

    /*
     * Local variables and signals
     */
    (* ram_style = "block" *)
    logic [11:0] frame_buffer [0:1023] [0:767] [0:1];

    wire current_buffer, currnet_buffer_hs;

    wire [10:0] vga_hcount, vga_vcount;
    wire vga_hsync, vga_hblnk, vga_vsync, vga_vblnk;



    /*
     * Signals assignments
     */

    

    /*
     * Submodules instances
     */

    buffer_swapper u_buffer_swapper(
        .clk_vga(),
        .clk_core(),
        .rst_n(rst_n),

        .vblank_in(vga_vblnk),

        .current_buffer_ls(current_buffer_ls),
        .currnet_buffer_hs(currnet_buffer_hs)

    );

    vga_timing u_vga_timing (
        .clk(clk_vga),
        .rst_n(rst_n),

        .vcount(vga_vcount),
        .vsync(vga_vsync),
        .vblnk(vga_vblnk),
        .hcount(vga_hcount),
        .hsync(vga_hsync),
        .hblnk(vga_hblnk)
    );

    vga_controller u_vga_controller (
        .clk(clk_vga),
        .rst_n(rst_n),

        .frame_buffer(frame_buffer),
        .current_buffer(current_buffer_ls),

        .vcount_in(vga_vcount),
        .vsync_in(vga_vsync),
        .vblnk_in(vga_vblnk),
        .hcount_in(vga_hcount),
        .hsync_in(vga_hsync),
        .hblnk_in(vga_hblnk),

        .vga_out(vga_out)
    );

    core_buffer_controller u_core_buffer_controller (
        .clk(clk_core),
        .rst_n(rst_n),

        .frame_buffer(frame_buffer),
        .current_buffer(current_buffer_hs),

        .new_frame_request(send_new_frame),

        .igb_in(igb_in)
    );



endmodule