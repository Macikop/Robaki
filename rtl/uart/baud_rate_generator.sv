/*
 * Designed by KS
 * How it works:
 * 
 * generaters clock for uart
 *  
 */

module baud_rate_generator #(
    parameter CLK_FREQUENCY = 100_000_000,
    parameter BAUD_RATE = 115200
)(
    input  logic       clk100MHz,
    input  logic       rst_n,
    output logic       baud_tick
);

    localparam int DIVISOR = CLK_FREQUENCY / (BAUD_RATE * 16);
    
    localparam int WIDTH = $clog2(DIVISOR);

    logic [WIDTH-1:0] counter_reg;

    always_ff @(posedge clk100MHz or negedge rst_n) begin
        if (!rst_n) begin
            counter_reg <= '0;
            baud_tick   <= 1'b0;
        end else begin
            if (counter_reg == (DIVISOR - 1)) begin
                counter_reg <= '0;
                baud_tick   <= 1'b1; 
            end else begin
                counter_reg <= counter_reg + 1'b1;
                baud_tick   <= 1'b0;
            end
        end
    end

endmodule
