/*
 * Designed by MP
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_robaki (
        input  wire clk,
        input  wire btnC,
        input  wire sw[1:0], //sw[0] - mute, sw[1] - volume
        inout  wire PS2Clk,
        inout  wire PS2Data,
        output wire [4:0] led,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA[3:0]  //JA[0] - AIN, JA[1] - GAIN, JA[2] - NC, JA[3] - SHUT_N
    );

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local variables and signals 
     */

    wire clk_in, clk_fb, clk_ss, clk_out;
    wire locked;
    wire pclk;
    wire clk_core;
    wire pclk_mirror;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)
    logic [7:0] safe_start = 0;
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


    /**
     * Signals assignments
     */

    assign pclk_mirror = pclk;
    assign clk_ss = clk_core;
    assign JA[2] = 1'b0;


    /**
     * FPGA submodules placement
     */



    always_ff @(posedge clk_ss)
        safe_start <= {safe_start[6:0],locked};

    

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.

    clk_wiz_0 u_clk_wiz_0 (
        .clk_core_ce(1'b1),
        .clk_core(clk_core),
        .clk_vga_audio_ce(1'b1),
        .clk_vga_audio(pclk),
        .locked(locked),
        .clk(clk)
    );


    /**
     *  Project functional top module
     */

    top_game #(
        .TERRAIN_PATH("../../rtl/vga_driver/maps/map1.dat"),
        .MUSIC_PATH("../../rtl/audio_driver/music_files/nokia_ringtone.hex")
    ) u_top_game (
        .clk_core  (clk_core),
        .clk_media (pclk),
        .rst_n     (~btnC),
        .ps2_data  (PS2Data),
        .ps2_clk   (PS2Clk),
        .mute_in   (sw[0]),
        .volume_in (sw[1]),
        .audio     (JA[0]),
        .shutdown  (JA[3]),
        .gain      (JA[1]),
        .r         (vgaRed),
        .g         (vgaGreen),
        .b         (vgaBlue),
        .vs        (Vsync),
        .hs        (Hsync),
        .debug_up(led[0]),
        .debug_down(led[1]),
        .debug_right(led[2]),
        .debug_left(led[3]),
        .debug_space(led[4])
    );

endmodule
