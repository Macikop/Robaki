/*
 * Designed by MP
 * 
 * How it works:
 * Generates pseudorandom numbers using a pipelined 32-bit XORSHIFT.
 */

module rng #(
    parameter OUTPUT_WIDTH = 8,             /* must be in <1:32> */
    parameter [31:0] SEED  = 32'hACE1,      /* starting value for generator */
    parameter [31:0] SPREAD = 32'h5555_5555 /* next stages use SEED with spread applied */
)(
    input  logic clk,
    input  logic rst_n,
    
    input  logic capture,

    output logic [OUTPUT_WIDTH-1:0] random_number
);

    logic [31:0] random_number_nxt [0:2];
    logic [31:0] random_number_reg [0:2];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            random_number <= '0;

            random_number_reg[0] <= SEED;
            random_number_reg[1] <= SEED ^ SPREAD;
            random_number_reg[2] <= SEED ^ (SPREAD * 2);

        end else begin
            if (capture) begin
                random_number <= random_number_nxt[2][31:32-OUTPUT_WIDTH];
            end

            random_number_reg[0] <= random_number_nxt[0];
            random_number_reg[1] <= random_number_nxt[1];
            random_number_reg[2] <= random_number_nxt[2];
        end
    end

    always_comb begin
        random_number_nxt[0] = random_number_reg[2] ^ (random_number_reg[2] << 13);
        random_number_nxt[1] = random_number_reg[0] ^ (random_number_reg[0] >> 17);        
        random_number_nxt[2] = random_number_reg[1] ^ (random_number_reg[1] << 5);
    end

endmodule