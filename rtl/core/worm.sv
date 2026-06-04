/*
 * Designed by MP
 * 
 * How it works:
 * 
 */

module worm(
    input  logic clk,
    input  logic rst_n,

    input  logic walking_stage,
    input  logic damage,
    input  logic damage enable,

    input  logic pos_x,
    input  logic pos_y,

    output logic [21:0] position,   /* {posy[10:0], posx[10:0]} */

);

    logic [6:0]     health;         /* health max 100*/
    logic [10:0]    pos_x;
    logic [10:0]    pos_y;
    logic [6:0]     aim;            /* {aim_dir - (1 - right 0 - left), aim value - (0 top down, 64 top up)} */


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            health <= 7'd100;
        end else begin
            
        end
        
        
    end
    


endmodule