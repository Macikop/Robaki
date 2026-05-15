/*
 * Designed by MP
 * 
 * How it works:
 * 
 */

module terrain_ram #(
    parameter int WIDTH  = 1024,
    parameter int HEIGHT = 768,
    parameter string TERRAIN_FILE_PATH = "../../rtl/vga_driver/maps/map1.dat"
)(
    input  logic clk_vga,
    input  logic clk_core,

    input  logic rst_n,

    input  logic [$clog2(WIDTH * HEIGHT)-1:0] address_vga,
    input  logic [$clog2(WIDTH * HEIGHT)-1:0] address_core,

    input  logic clear,

    output logic data_out_vga,
    output logic data_out_core
);

    localparam int SIZE = WIDTH * HEIGHT;

    logic rom [0:SIZE-1];


    /*
     * Memory initialization from a file
     */

    initial begin
        $readmemh(TERRAIN_FILE_PATH, rom);
    end

    /*
     * Internal logic
     */

    always_ff @(posedge clk_vga) begin
        if (!rst_n) begin
            data_out_vga <= 1'b0;
        end else begin
            data_out_vga <= rom[address_vga];
        end
    end

    always_ff @(posedge clk_core) begin
        if (!rst_n) begin
            data_out_core <= 1'b0;
        end else begin
            if (clear) begin
                rom[address_core] <= 1'b0;
            end            
            data_out_core <= rom[address_core];
        end
    end

endmodule
