/* Designed by KS
 * 
 * key_decoder: receives raw byte key code, outputs which key was pressed
*/

module key_decoder (
    input logic clk,
    input logic rst_n,

    input logic [7:0] key_code,
    input logic done,

    output logic up, down, left, right, space, tab      //keys, possible to add more
    );

    logic is_break;     //track if previous code was 0xF0

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            up <= '0;
            down <= '0;
            left <= '0;
            right <= '0;
            space <= '0;
            tab <= '0;
            is_break <= '0;
        end else if (done) begin
            if (key_code == 0'hf0) begin
                is_break <= '1;
            end else begin
                case (key_code)
                    8'h75: up <= !is_break;     //up
                    8'h72: down <= !is_break;     //down
                    8'h6b: left <= !is_break;     //left
                    8'h74: right <= !is_break;     //right
                    8'h29: space <= !is_break;     //spacebar
                    8'h0d: tab <= !is_break;     //tab
                    default: ;
                endcase
                is_break <= '0;     //reset break state
            end
        end
    end
endmodule