/* Designed by KS
 * 
 * top_keyboard_driver: receives data through ps2 
 * and outputs which key was pressed (up, down, left, right, space, tab)
*/

module top_keyboard_driver (
    input logic clk,
    input logic rst_n,

    input logic ps2_clk,
    input logic ps2_data,

    output logic up, down, left, right, space, tab
    );

    logic [7:0] key_code;
    logic done;

    ps2_interface u_ps2_interface (
        .clk,
        .rst_n,
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .key_code(key_code),
        .done(done)
    );

    key_decoder u_key_decoder (
        .clk,
        .rst_n,
        .key_code(key_code),
        .done(done),
        .up,
        .down,
        .left,
        .right,
        .space,
        .tab
    );

endmodule