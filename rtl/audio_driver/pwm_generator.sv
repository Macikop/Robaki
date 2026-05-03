/*
 * Designed by MP
 * 
 * How it works:
 * Generates pwm pulse at every sync signal, pulse is 256 clk long and specified width
 */


module pwm_generator (
    input  logic clk,
    input  logic rst_n,

    input  logic sync,          /* every 256 clk cycles */
    input  logic [7:0] width,
    
    output logic wave_out
);

    logic [7:0] timer;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            timer <= '0;
            wave_out <= '0;
        end else if (sync) begin
            timer <= '0;
            wave_out <= (0 < width);
        end else begin
            timer <= timer + 1;
            wave_out <= ((timer + 1) < width);
        end
    end

endmodule
