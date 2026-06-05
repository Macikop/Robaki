/*
 * Designed by MP
 * 
 * How it works:
 * Time-Digital Converter - converts time of holding key to value.
 * Measurement with accuracy to sync. Sets done on falling edge of pulse.
 */

module tdc #(
    parameter MAX_TIME = 255
)(
    input  logic clk,
    input  logic rst_n,

    input  logic sync,
    input  logic enable,

    input  logic pulse,

    output logic [$clog2(MAX_TIME + 1)-1:0] value,
    output logic done
);

    logic [$clog2(MAX_TIME)-1:0] value_nxt;
    logic pulse_buf;
    logic done_nxt;

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            value <= '0;
            done <= '0;
            pulse_buf <= '0;
        end else begin
            value <= value_nxt;
            done <= done_nxt;
            pulse_buf <= pulse;
        end
        
    end
    
    always_comb begin
        value_nxt = value;
        done_nxt = '0;

        if (enable) begin
            if (sync) begin
                if (pulse) begin
                    done_nxt = 1'b0;
                    value_nxt = (value == MAX_TIME) ? value : value + 1;
                end else begin
                    if (pulse_buf) begin
                        value_nxt = value;
                        done_nxt = 1'b1;
                    end
                end         
            end
        end else begin
            value_nxt = '0;
        end
    end
    
endmodule
