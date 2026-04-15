/* Designed by MP
 * 
 * How it works:
 * gets graphics data via IGB from core and sends it into one of the buffer that is not used for displaying at the moment
 */

module core_buffer_controller (
    input  logic clk,
    input  logic rst_n,

    output logic [11:0] frame_buffer [0:1023] [0:767] [0:1];
    input  logic current_buffer;

    output logic new_frame_request,    
    igb_if.in igb_in
);

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /*
     * Local variables and signals
     */

    logic [11:0] rgb_nxt;
    logic [10:0] hcount_nxt, vcount_nxt;
    logic current_buffer_nxt;

    logic current_buffer_buf;

    
    /*
     * Internal logic
     */

    always_ff @(posedge clk or negedge rst_n) begin : bg_ff_blk
        if (!rst_n) begin
            frame_buffer <= '0;
            current_buffer_buf <= 1b'0;
        end else begin
            frame_buffer[hcount_nxt][vcount_nxt][current_buffer_nxt] = rgb_nxt;
            current_buffer_buf <= current_buffer;
        end
    end

    always_comb begin : bg_comb_blk
        current_buffer_nxt = current_buffer;
        hcount_nxt = igb_in.hcount;
        vcount_nxt = igb_in.vcount;
        rgb_nxt = igb_in.rgb;
        new_frame_request = current_buffer & ~ current_buffer_buf;
    end


endmodule