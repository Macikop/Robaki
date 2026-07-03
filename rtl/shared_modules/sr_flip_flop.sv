/*
 * Designed by MP
 * 
 * How it works:
 * SR ff with priority 
 */

module sr_flip_flop #(
    parameter string PRIORITY = "RESET" /* Options: "RESET" or "SET" */
)(
    input  logic clk,
    input  logic rst_n,
    input  logic s,
    input  logic r,
    output logic q
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 1'b0;
        end else begin
            case ({s, r})
                2'b00 : q <= q;
                2'b01 : q <= 1'b0;
                2'b10 : q <= 1'b1;
                
                2'b11 : begin
                    if (PRIORITY == "SET") begin
                        q <= 1'b1;
                    end else begin
                        q <= 1'b0;
                    end
                end
                
                default: q <= q;
            endcase
        end
    end

endmodule