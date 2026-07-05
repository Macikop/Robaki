/*
 * Designed by MP
 * 
 * How it works:
 * Calculates damage and kickback from explosion 
 */

module explosion_consequences(
    input  logic clk,
    input  logic rst_n,

    input  logic [10:0] worm_pos_x,
    input  logic [10:0] worm_pos_y,

    input  logic [10:0] explosion_pos_x,
    input  logic [10:0] explosion_pos_y,
    input  logic [10:0] explosion_r,

    input  logic start,

    output logic signed [7:0] velocity_x,
    output logic signed [7:0] velocity_y,

    output logic [5:0] damage,

    output logic done
);

    typedef enum logic [2:0] {
        IDLE, 
        DIV,
        MIN_MAX,
        APPROX,
        DONE
    } state_t;
    
    state_t state, state_nxt;

    logic signed [7:0] velocity_x_nxt;
    logic signed [7:0] velocity_y_nxt;

    logic signed [7:0] dx, dy, max_d, min_d, approx_r;
    logic signed [7:0] dx_nxt, dy_nxt, max_d_nxt, min_d_nxt, approx_r_nxt;

    logic done_nxt;
    logic [5:0] damage_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            velocity_x <= '0;
            velocity_y <= '0;
            damage <= '0;    
            done <= '0;

            dx <= '0;
            dy <= '0;
            max_d <= '0;
            min_d <= '0;
            approx_r <= '0;

        end else begin
            state <= state_nxt;
            velocity_x <= velocity_x_nxt;
            velocity_y <= velocity_y_nxt;
            damage <= damage_nxt;    
            done <= done_nxt;

            dx <= dx_nxt;
            dy <= dy_nxt;
            max_d <= max_d_nxt;
            min_d <= min_d_nxt;
            approx_r <= approx_r_nxt;
        end 
    end

    always_comb begin
        velocity_x_nxt = velocity_x;
        velocity_y_nxt = velocity_y;

        dx_nxt = dx;
        dy_nxt = dy;
        max_d_nxt = max_d;
        min_d_nxt = min_d;
        approx_r_nxt = approx_r;

        damage_nxt = '0;
        done_nxt = 1'b0;

        case (state)

            IDLE: begin
                velocity_x_nxt = '0;
                velocity_y_nxt = '0;
                damage_nxt = '0;

                done_nxt = 1'b0;

                state_nxt = start ? DIV : IDLE;
            end

            DIV: begin
                dx_nxt = (worm_pos_x > explosion_pos_x) ? (worm_pos_x - explosion_pos_x) : (explosion_pos_x - worm_pos_x);
                dy_nxt = (worm_pos_y > explosion_pos_y) ? (worm_pos_y - explosion_pos_y) : (explosion_pos_y - worm_pos_y);
                state_nxt = MIN_MAX;
            end

            MIN_MAX: begin
                max_d_nxt = (dx > dy) ? dx : dy;
                min_d_nxt = (dx > dy) ? dy : dx;
                state_nxt = APPROX;
            end

            APPROX: begin
                approx_r_nxt = max_d + (min_d >> 2) + (min_d >> 3);
                state_nxt = DONE;
            end
            
            DONE: begin
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
