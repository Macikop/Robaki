/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Robert Szczygiel
 * Modified: Piotr Kaczmarczyk
 * Modified: Maciej Piofczyk - added transparecy bit and parameters
 *
 * Description:
 * This is the ROM for the 'AGH48x64.png' image.
 * The image size is 48 x 64 pixels.
 * The input 'address' is a 12-bit number, composed of the concatenated
 * 6-bit y and 6-bit x pixel coordinates.
 * The output 'rgb' is 12-bit number with concatenated
 * red, green and blue color values (4-bit each)
 */

module sprite_rom #(
    parameter int WIDTH  = 32,
    parameter int HEIGHT = 32,
    parameter string SPRITE_PATH = "../../rtl/vga_driver/sprite_bank/arrow.dat"
)(
    input  logic clk,
    input  logic [$clog2(WIDTH*HEIGHT)-1:0] address,
    output logic [12:0] rgb
);

    function automatic int next_pow2(input int x);
        int v;
        begin
            v = 1;
            while (v < x)
                v = v << 1;
            return v;
        end
    endfunction

    localparam int SIZE = next_pow2(WIDTH) * next_pow2(HEIGHT);

    logic [12:0] rom [0:SIZE-1];


    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh(SPRITE_PATH, rom);


    /**
     * Internal logic
     */

    always_ff @(posedge clk)
        rgb <= rom[address];

endmodule
