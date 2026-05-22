/*
 * Designed by MP
 * 
 * How it works:
 * It is ROM where music sits
 */

module music_rom #(
    parameter FILE_SIZE = 16,
    parameter FILE_PATH = "../../rtl/audio_driver/music_files/nokia_ringtone.hex"
)(
    input logic clk,
    input logic rst_n,

    input logic [$clog2(FILE_SIZE):0] address,
    output logic [31:0] value
);

    logic [31:0] rom [0:FILE_SIZE];

    initial begin
        $readmemh(FILE_PATH, rom);
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            value <= '0;
        end else begin
            value <= rom[address];
        end
    end   

endmodule