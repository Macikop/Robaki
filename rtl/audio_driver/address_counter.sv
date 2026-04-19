/*
 * Designed by MP
 * 
 * How it works:
 * Adress counter for DDS.
 */

module address_counter(
    input clk,
    input rst_n,

    input  [31:0] phase_increment,
    input  sync_in,

    output [7:0]  sine_addr,
    output sync_out
);

    logic [31:0] phase;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            phase <= '0;
        end else if (sync_in) begin
            phase <= phase + phase_increment; 
        end
    end
    
    assign sine_addr = phase[31:24];
    assign sync_out = sync_in;
    
endmodule
