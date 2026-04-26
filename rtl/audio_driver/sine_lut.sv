module sine_lut(
    input logic clk,
    input logic rst_n,

    input  logic [7:0] addr,
    output logic [7:0] value
);

    logic [7:0] rom [0:255];

    initial begin
        $readmemh("../../rtl/audio_driver/luts/sine.dat", rom);
    end
    

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            value <= '0;
        end else begin
            value <= rom[addr];
        end
    end   

endmodule