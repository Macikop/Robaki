/**
 * San Jose State University
 * EE178 Lab #4
 * Author: prof. Eric Crabilla
 *
 * Modified by:
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Piotr Kaczmarczyk
 *
 * Description:
 * Top level synthesizable module including the project top and all the FPGA-referred modules.
 */

module top_vga_basys3 (
        input  wire clk,
        input  wire btnC,
        input  wire sw[1:0], //sw[0] - mute, sw[1] - volume
        inout  wire PS2Clk,
        inout  wire PS2Data,
        output wire Vsync,
        output wire Hsync,
        output wire [3:0] vgaRed,
        output wire [3:0] vgaGreen,
        output wire [3:0] vgaBlue,
        output wire JA1,
        output wire JA[3:1], //JA2 - shutdown, JA3 - gain, JA4 - AIN
        output wire an[3:0],
        output wire seg[6:0]
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

    //keyboard
    wire up, down, left, right, space, tab;
    assign seg[5:0] = {up, down, left, right, space, tab};
    assign an[0] = '0;

    (* KEEP = "TRUE" *)
    (* ASYNC_REG = "TRUE" *)
    logic [7:0] safe_start = 0;
    // For details on synthesis attributes used above, see AMD Xilinx UG 901:
    // https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Synthesis-Attributes


    /**
     * Signals assignments
     */

    assign JA1 = pclk_mirror;


    /**
     * FPGA submodules placement
     */



    always_ff @(posedge clk_ss)
        safe_start <= {safe_start[6:0],locked};

    

    // Mirror pclk on a pin for use by the testbench;
    // not functionally required for this design to work.

    clk_wiz_0 u_clk_wiz_0 (
        .clk_core(clk_core),
        .clk_vga_audio(pclk),
        .locked(locked),
        .clk(clk)
    );


    /**
     *  Project functional top module
     */

 
    top_audio_driver u_top_audio_driver(
        .clk(pclk),
        .rst_n(~btnC),
        .mute(sw[0]),
        .volume(sw[1]),
        .wave_out(JA[3]),
        .gain(JA[2]),
        .shoutdown(JA[1])
    );

    top_keyboard_driver u_top_keyboard_driver(
        .clk(clk_core),
        .rst_n(~btnC),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .up(up),
        .down(down),
        .left(left),
        .right(right),
        .space(space),
        .tab(tab)
    );

endmodule
