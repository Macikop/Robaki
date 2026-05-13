/*
 * Designed by MP
 * 
 */

module terrain_rom #(
    parameter int WIDTH  = 1024,
    parameter int HEIGHT = 768,
    parameter string TERRAIN_FILE_PATH = "../../rtl/vga_driver/maps/map1.dat"
)(
    input  logic clk,
    input  logic rst_n,
    input  logic [$clog2(WIDTH * HEIGHT)-1:0] address,
    output logic is_occupied
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

    logic rom [0:SIZE-1];


    /**
     * Memory initialization from a file
     */

    /* Relative path from the simulation or synthesis working directory */
    initial $readmemh(TERRAIN_FILE_PATH, rom);


    /**
     * Internal logic
     */

    always_ff @(posedge clk) begin
    if (!rst_n) begin
        is_occupied <= 1'b0;
    end else begin
        is_occupied <= rom[address];
    end
end

endmodule
