/*
 * Designed by KS
 * How it works:
 * converts active-high keyboard flags into a single byte
 *  
 */

module key_encoder (
    input  logic       clk,
    input  logic       up, down, left, right, tab, space,
    output logic [7:0] key_code,
    output logic       key_valid
);

    logic [7:0] last_code;
    
    always_ff @(posedge clk) begin
        key_valid <= 1'b1;
        if      (up)    key_code <= 8'h57;   // 'W'
        else if (down)  key_code <= 8'h53;   // 'S'
        else if (left)  key_code <= 8'h41;   // 'A'
        else if (right) key_code <= 8'h44;   // 'D'
        else if (tab)   key_code <= 8'h09;   // Tab
        else if (space) key_code <= 8'h20;   // Space
        else begin
            key_code  <= 8'h00;
            key_valid <= 1'b0;
        end
    end

endmodule
