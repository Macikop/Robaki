/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Piotr Kaczmarczyk
 *
 * Description:
 * Vga timing controller.
 */

module vga_timing (
        input  logic clk,
        input  logic rst_n,
        output logic [10:0] vcount,
        output logic vsync,
        output logic vblnk,
        output logic [10:0] hcount,
        output logic hsync,
        output logic hblnk
    );

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     * Local variables and signals
     */

    logic [10:0] vcount_nxt, hcount_nxt;
    logic vsync_nxt, vblnk_nxt, hsync_nxt, hblnk_nxt;


    /**
     * Internal logic
     */

    always_ff @(posedge clk or negedge rst_n) begin
    
        if (!rst_n) begin
    
            vcount <= 11'b0;
            hcount <= 11'b0;
    
            vsync <= 1'b0;
            vblnk <= 1'b0;
            hsync <= 1'b0;
            hblnk <= 1'b0;
    
        end else begin
            vcount <= vcount_nxt;
            hcount <= hcount_nxt;
            vsync <= vsync_nxt;
            vblnk <= vblnk_nxt;
            hsync <= hsync_nxt;
            hblnk <= hblnk_nxt;
        end
    end
    
    always_comb begin
        vcount_nxt = vcount; 
        hcount_nxt = hcount + 1; 
        vsync_nxt = vsync; 
        vblnk_nxt = vblnk; 
        hsync_nxt = hsync; 
        hblnk_nxt = hblnk; 
    
        hblnk_nxt = ((hcount >= (HOR_BLANK_START - 1)) && (hcount < (HOR_BLANK_START + HOR_BLANK_TIME - 1)));
        hsync_nxt = ((hcount >= (HOR_SYNC_START - 1)) && (hcount < (HOR_SYNC_START + HOR_SYNC_TIME - 1)));
    
        if (hcount == HOR_TOTAL_TIME - 1) begin
            hcount_nxt = 11'b0;
    
            vcount_nxt = (vcount == (VER_TOTAL_TIME - 1)) ? 11'b0 : vcount + 1;
    
            vblnk_nxt = ((vcount >= (VER_BLANK_START - 1)) && (vcount < (VER_BLANK_START + VER_BLANK_TIME - 1)));
            vsync_nxt = ((vcount >= (VER_SYNC_START - 1)) && (vcount < (VER_SYNC_START + VER_SYNC_TIME - 1)));
    
        end
    end

endmodule
