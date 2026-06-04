/*
 * Designed by MP
 * 
 * How it works:
 * Switches between modules that tries to access RAM
 * Only one at the time is allowed
 */


module ram_address_mux #(
    parameter ADDRESS_WIDTH = 20,
    parameter INPUTS_NUMBER = 3
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [ADDRESS_WIDTH-1:0] addresses [0:INPUTS_NUMBER-1],

    output logic [ADDRESS_WIDTH-1:0] ram_address
);

    logic [ADDRESS_WIDTH-1:0] ram_address_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ram_address <= '0;
        end else begin
            ram_address <= ram_address_nxt;
        end
    end

    always_comb begin
        ram_address_nxt = '0;

        for (int i = 0; i < INPUTS_NUMBER; i++) begin
            if (addresses[i]) begin
                ram_address_nxt = addresses[i];
                break;
            end
        end
    end

endmodule
