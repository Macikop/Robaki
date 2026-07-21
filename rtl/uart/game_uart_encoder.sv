/* Designed by KS
 * Encodes player parameters into 32-bit packets ready to be sent
 */

module game_uart_encoder(
    input logic clk,
    input logic rst_n,
    input logic vsync,
    input logic [3:0] current_state,
    input logic current_player,

    input logic [10:0] worm_1_xpos,
    input logic [10:0] worm_1_ypos,

    input logic [7:0] aim_angle,
    input logic [7:0] shot_power,

    input logic [10:0] bullet_x,
    input logic [10:0] bullet_y,

    input logic [7:0] explosion_radius,

    input logic [6:0] worm_1_health,

    output logic [31:0] data32_out,

    output logic start
    );

    timeunit 1ns;
    timeprecision 1ps;

    logic [3:0] state_id;
    logic [2:0] extra;
    logic [23:0] payload;

    assign state_id = current_state;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            data32_out <= '0;
            start <= '0;
        end else begin        
            if(vsync && !start) begin
                data32_out <= {current_state, current_player, extra, payload};
                start <= 1'b1;
            end else begin
                start <= '0;
            end
        end
    end

    always_comb begin
        extra = 3'b000;
        payload = '0;

        case (state_id)
            4'd0: begin
                payload = '0;
            end
            4'd1: begin
                payload = {1'b0, worm_1_xpos, 1'b0, worm_1_ypos};
            end
            4'd2: begin
                payload = {4'b0, aim_angle, 4'b0, shot_power};
            end
            4'd3: begin
                payload = {1'b0, bullet_x, 1'b0, bullet_y};
            end
            4'd4: begin
                payload = {16'b0, explosion_radius};
            end
            4'd5: begin
                payload = '0;
            end
            4'd6: begin
                payload = {17'b0, worm_1_health};
            end
        endcase
    end

endmodule