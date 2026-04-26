/*
 * Designed by MP 
 */

module phase_increment_lut (
    input logic clk,
    input logic rst_n,

    input logic [5:0] addr,
    output logic [31:0] value
);

    logic [31:0] rom [0:37];

    initial begin
        $readmemh("../../rtl/audio_driver/luts/phase.dat", rom);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            value <= '0;
        end else begin
            value <= rom[addr];
        end
    end

endmodule