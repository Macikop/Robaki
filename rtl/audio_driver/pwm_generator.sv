/*
 * Designed by MP
 * 
 * How it works:
 * Generates pwm pulse at every sync signal, pulse is 64 clk long and specified width
 */


module pwm_generator (
    input  logic clk,
    input  logic rst_n,

    output logic wave_out,

    input  logic sync,          /* every 256 clk cycles */
    input  logic [7:0] width    
);

    logic [7:0] timer;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            timer <= '0;
        end else  if (sync) begin
            timer <= '0;
        end else begin
            timer <= timer + 1;
        end
    end

    assign wave_out = rst_n ? (timer < width) : 1'b0;

endmodule
