/* Designed by KS
 * 
 * top_keyboard_driver: receives data through ps2 
 * and outputs which key was pressed ((W)up, (S)down, (A)left, (D)right, SPACE, TAB)
*/

module top_keyboard_driver (
    input logic clk,
    input logic rst_n,
    
    input logic sync,

    inout logic ps2_clk,
    inout logic ps2_data,

    output logic up, down, left, right, space, tab
    );

    logic [7:0] key_code;
    logic done;

    logic dec_up, dec_down, dec_left, dec_right, dec_space, dec_tab;

    Ps2Interface u_Ps2Interface (
        .clk,
        .rst(~rst_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),

        .rx_data(key_code),
        .read_data(done),

        .tx_data(),
        .write_data(),
        .busy(),
        .err()
    );

    key_decoder u_key_decoder (
        .clk,
        .rst_n,
        .key_code(key_code),
        .done(done),
        .up(dec_up),
        .down(dec_down),
        .left(dec_left),
        .right(dec_right),
        .space(dec_space),
        .tab(dec_tab)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            up    <= 1'b0;
            down  <= 1'b0;
            left  <= 1'b0;
            right <= 1'b0;
            space <= 1'b0;
            tab   <= 1'b0;
        end else if (sync) begin
            up    <= dec_up;
            down  <= dec_down;
            left  <= dec_left;
            right <= dec_right;
            space <= dec_space;
            tab   <= dec_tab;
        end
    end

endmodule