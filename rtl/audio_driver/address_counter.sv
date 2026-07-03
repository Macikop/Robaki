/*
 * Designed by MP
 * 
 * How it works:
 * Adress counter for DDS.
 */

module address_counter(
    input  logic clk,
    input  logic rst_n,

    input  logic[31:0] phase_increment,
    input  logic sync_in,

    output logic [7:0]  sine_addr,
    output logic sync_out
);

    logic [31:0] phase;
    logic [31:0] phase_increment_d;  // pipeline for synchronous LUT output
    logic sync_in_d;                  // pipeline sync signal

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            phase <= '0;
            phase_increment_d <= '0;
            sync_in_d <= '0;
        end else begin
            phase_increment_d <= phase_increment;  // stage 1: capture LUT output
            sync_in_d <= sync_in;
            
            if (sync_in_d) begin
                phase <= phase + phase_increment_d;  // stage 2: use pipelined increment
            end
        end
    end
    
    assign sine_addr = phase[31:24];
    assign sync_out = sync_in_d;  // delay sync to match data pipeline
    
endmodule
