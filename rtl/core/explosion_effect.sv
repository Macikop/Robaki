/*
 * Designed by MP
 * 
 * How it works:
 * Generates signals to draw exploison (using draw_circle)
 */

module explosion_effect (
    input  logic clk,
    input  logic rst_n,
    input  logic sync,

    input  logic explosion_enable,

    input  logic [10:0] explosion_x,
    input  logic [10:0] explosion_y,
    input  logic [7:0] expolsion_radius,

    output logic draw_enable,
    output logic [10:0] pos_x,
    output logic [10:0] pos_y,
    output logic [10:0] radius,
    output logic [11:0] color,

    output logic done
);

    typedef enum logic [1:0] {
        IDLE,
        YELLOW,
        ORANGE,
        RED
    } state_t;

    logic [10:0] pos_x_nxt;
    logic [10:0] pos_y_nxt;
    logic [10:0] radius_nxt;
    logic [11:0] color_nxt;
    logic enable_draw_nxt;
    logic done_nxt;

    logic explosion_disabled, explosion_disabled_nxt;

    state_t state, state_nxt;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;

            pos_x <= '0;
            pos_y <= '0;
            radius <= '0;
            color <= '0;
            draw_enable <= '0;
            done <= '0;

            explosion_disabled <= '0;

        end else begin
            state <= state_nxt;

            pos_x <= pos_x_nxt;
            pos_y <= pos_y_nxt;
            radius <= radius_nxt;
            color <= color_nxt;
            draw_enable <= enable_draw_nxt;
            done <= done_nxt;

            explosion_disabled <= explosion_disabled_nxt;
        end
    end

    always_comb begin

        explosion_disabled_nxt = explosion_disabled;

        pos_x_nxt = explosion_x;
        pos_y_nxt = explosion_y;
        radius_nxt = {3'b0, expolsion_radius};

        enable_draw_nxt = 1'b0;
        
        if(!explosion_enable) begin
            explosion_disabled_nxt = 1'b0;
        end
        
        
        case (state)
            IDLE: begin
                done_nxt = 1'b0;
                state_nxt = (explosion_enable && sync && !explosion_disabled) ? YELLOW : IDLE;
            end

            YELLOW: begin
                state_nxt = (sync) ? ORANGE : YELLOW;
                enable_draw_nxt = 1'b1;
                color_nxt = 12'hF_F_0;
            end

            ORANGE: begin
                state_nxt = (sync) ? RED : ORANGE;
                enable_draw_nxt = 1'b1;
                color_nxt = 12'hF_A_0;
            end
            
            RED: begin
                state_nxt = (sync) ? IDLE : RED;
                color_nxt = 12'hF_0_0;
                enable_draw_nxt = 1'b1;
                explosion_disabled_nxt = 1'b1;
                done_nxt = 1'b1;
            end
            
            default: begin
                state_nxt = IDLE;
            end
            
        endcase
        
    end

endmodule
