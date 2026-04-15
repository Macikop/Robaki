/* Designed by MP
 * 
 * How it works:
 * swaps buffers on every vblank posedge
 */

module buffer_swapper (
    input  logic clk_vga,
    input  logic clk_core,
    input  logic rst_n,

    input  logic vblank_in,

    output  logic current_buffer_ls;    //low speed  - vga
    output  logic currnet_buffer_hs;    //high speed - core

    );

    timeunit 1ns;
    timeprecision 1ps;

    /*
     * Local variables and signals
     */

    (* ASYNC_REG = "TRUE" *)
    logic [1:0] sync_ff;

    
    logic vblank_buf;
    logic current_buffer_ls_nxt;
    
    /*
     * Internal logic
     */

    always_ff @(posedge clk_vga or negedge rst_n) begin : 
        if (!rst_n) begin
            current_buffer <= '0;
            vblank_buf <= 1'b0;     
        end else begin
            current_buffer_ls <= current_buffer_nxt;
            vblank_buf <= 1'b0;
        end
    end

    always_comb begin
        if(vblank_in & ~vblank_buf) begin
            current_buffer_nxt = ~current_buffer_ls;
        end
        
    end

    always_ff @(posedge clk_core or negedge rst_n) begin
        if (!rst_n)begin
            sync_ff <= '0;
        end else begin
            sync_ff <= {sync_ff[0], current_buffer_nxt}
        end
    end

    assign currnet_buffer_hs = ~sync_ff[1];
    

endmodule