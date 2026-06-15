/* Designed by KS
 * Decodes received packets and
 * outputs current player 1 parameters
 */ 

module game_uart_decoder(
    input logic clk,
    input logic rst_n,

    input logic [3:0] current_state_in,
    input logic current_player_in,
    input logic [23:0] payload,

    output logic current_player,

    output logic [10:0] worm_1_xpos,
    output logic [10:0] worm_1_ypos,

    output logic [7:0] aim_angle,
    output logic [7:0] shot_power,

    output logic [10:0] bullet_x,
    output logic [10:0] bullet_y,

    output logic [7:0] explosion_radius,
    output logic [6:0] worm_1_health,

    output logic [3:0] current_state

    );

    timeunit 1ns;
    timeprecision 1ps;

    logic [10:0] worm_1_xpos_nxt;
    logic [10:0] worm_1_ypos_nxt;
    logic [7:0] aim_angle_nxt;
    logic [7:0] shot_power_nxt;
    logic [10:0] bullet_x_nxt;
    logic [10:0] bullet_y_nxt;
    logic [7:0] explosion_radius_nxt;
    logic [6:0] worm_1_health_nxt;


    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            current_state <= '0;
            current_player <= '0;

            worm_1_xpos <= '0;
            worm_1_ypos <= '0;
            aim_angle <= '0;
            shot_power <= '0;
            bullet_x <= '0;
            bullet_y <= '0;
            explosion_radius <= '0;
            worm_1_health <= '0;
        end else begin
            current_state <= current_state_in;
            current_player <= current_player_in;

            worm_1_xpos <= worm_1_xpos_nxt;
            worm_1_ypos <= worm_1_ypos_nxt;
            aim_angle <= aim_angle_nxt;
            shot_power <= shot_power_nxt;
            bullet_x <= bullet_x_nxt;
            bullet_y <= bullet_y_nxt;
            explosion_radius <= explosion_radius_nxt;
            worm_1_health <= worm_1_health_nxt;
        end
    end

    always_comb begin
        worm_1_xpos_nxt = worm_1_xpos;
        worm_1_ypos_nxt = worm_1_ypos;
        aim_angle_nxt = aim_angle;
        shot_power_nxt = shot_power;
        bullet_x_nxt = bullet_x;
        bullet_y_nxt = bullet_y;
        explosion_radius_nxt = explosion_radius;
        worm_1_health_nxt = worm_1_health;

        case(current_state_in)
            4'd0: begin

            end
            4'd1: begin
                worm_1_xpos_nxt = payload[22:12];
                worm_1_ypos_nxt = payload[10:0];
            end
            4'd2: begin
                aim_angle_nxt = payload[18:12];
                shot_power_nxt = payload[7:0];
            end
            4'd3: begin
                bullet_x_nxt = payload[22:12];
                bullet_y_nxt = payload[10:0];
            end
            4'd4: begin
                explosion_radius_nxt = payload[7:0];
            end
            4'd5: begin

            end
            4'd6: begin
                worm_1_health_nxt = payload[6:0];
            end
        endcase
    end


endmodule