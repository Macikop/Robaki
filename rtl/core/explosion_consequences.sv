/*
 * Designed by MP
 * 
 * How it works:
 * Calculates damage and kickback from explosion 
 */

module explosion_conseqences #(
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [$clog2(TERRAIN_WIDTH)-1:0] worm_pos_x,
    input  logic [$clog2(TERRAIN_HEIGHT)-1:0] worm_pos_y,

    input  logic [$clog2(TERRAIN_WIDTH)-1:0] explosion_pos_x,
    input  logic [$clog2(TERRAIN_HEIGHT)-1:0] explosion_pos_y,
    input  logic [10:0] explosion_r,

    input  logic start,

    output logic signed [7:0] velocity_x,
    output logic signed [7:0] velocity_y,

    output logic [5:0] damage,

    output logic done
);

    typedef enum logic {
        IDLE, 
        CALC
    } state_t;
    
    state_t state, state_nxt;

    logic signed [7:0] velocity_x_nxt;
    logic signed [7:0] velocity_y_nxt;

    logic signed [7:0] dx, dy, max_d, min_d, approx_r;

    logic done_nxt;
    logic [5:0] damage_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            velocity_x <= '0;
            velocity_y <= '0;
            damage <= '0;    
            done <= '0;
        end else begin
            state <= state_nxt;
            velocity_x <= velocity_x_nxt;
            velocity_y <= velocity_y_nxt;
            damage <= damage_nxt;    
            done <= done_nxt;
        end 
    end

    always_comb begin

        case (state)

            IDLE: begin
                velocity_x_nxt = '0;
                velocity_y_nxt = '0;
                damage_nxt = '0;

                done_nxt = 1'b0;

                state_nxt = start ? CALC : IDLE;
            end

            CALC: begin
                velocity_x_nxt = velocity_x;
                velocity_y_nxt = velocity_y;

                dx = (worm_pos_x > explosion_pos_x) ? (worm_pos_x - explosion_pos_x) : (explosion_pos_x - worm_pos_x);
                dy = (worm_pos_y > explosion_pos_y) ? (worm_pos_y - explosion_pos_y) : (explosion_pos_y - worm_pos_y);

                max_d = (dx > dy) ? dx : dy;
                min_d = (dx > dy) ? dy : dx;
                
                approx_r = max_d + (min_d >> 2) + (min_d >> 3);

                if (approx_r < explosion_r) begin
                    damage_nxt = explosion_r - approx_r;
                    velocity_x_nxt = explosion_r - dx;
                    velocity_y_nxt = explosion_r - dy;
                end else begin
                    velocity_x_nxt = '0;
                    velocity_y_nxt = '0;
                    damage_nxt = '0;
                end
                done_nxt = 1'b1;

                state_nxt = IDLE;
            end

            default: begin
                state_nxt = IDLE;
            end
            
        endcase
        
    end

endmodule
