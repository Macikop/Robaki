/*
 * Designed by MP
 * * Corrected version: Fixed orientation snap erasure during multi-cycle calculations.
 */

module aim #(
    parameter logic [7:0] AIM_DISTACNE = 50,
    parameter logic [10:0] X_OFFSET = 16,
    parameter logic [10:0] Y_OFFSET = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic enable,
    input  logic sync,
    
    input  logic up,
    input  logic down,

    input  logic signed [7:0] x_aim,
    input  logic signed [7:0] y_aim,

    input  logic [10:0] x_pos,
    input  logic [10:0] y_pos,
    input  logic orientation,

    input  logic calc_done,
    output logic start_calc,

    output logic [7:0] aim_angle,
    output logic [7:0] length,

    output logic [10:0] x_out,
    output logic [10:0] y_out
    
);

    typedef enum logic [1:0] {
        IDLE,
        START_CALC,
        WAIT_CALC,
        OUTPUT_VALUE
    } state_t;

    state_t state, state_nxt;

    logic start_calc_nxt;
    logic [7:0]aim_angle_nxt;
    logic [10:0] x_out_nxt;
    logic [10:0] y_out_nxt;

    logic orientation_d;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            start_calc <= '0;
            aim_angle <= '0;
            length <= AIM_DISTACNE;
            x_out <= '0;
            y_out <= '0;
            state <= IDLE;
            orientation_d <= 1'b0;
        end else begin
            start_calc <= start_calc_nxt;
            aim_angle <= aim_angle_nxt;
            length <= AIM_DISTACNE;
            x_out <= x_out_nxt;
            y_out <= y_out_nxt;
            state <= state_nxt;

            if(state == START_CALC) begin 
                orientation_d <= orientation;
            end
        end
    end

    always_comb begin
        start_calc_nxt = start_calc;
        aim_angle_nxt = aim_angle;
        x_out_nxt = x_out;
        y_out_nxt = y_out;
        state_nxt = state;

        case (state)
            IDLE: begin
                if (sync && enable) begin
                    if (up && !down) begin
                        if (orientation) begin 
                            aim_angle_nxt = (aim_angle < 64) ? (aim_angle + 1) : aim_angle;
                        end else begin
                            aim_angle_nxt = (aim_angle < 192) ? (aim_angle - 1) : aim_angle;
                        end
                    end else if (down && !up) begin
                        if (orientation) begin 
                            aim_angle_nxt = (aim_angle > 192) ? (aim_angle - 1) : aim_angle;
                        end else begin
                            aim_angle_nxt = (aim_angle > 64) ? (aim_angle + 1) : aim_angle;
                        end
                    end else begin
                        if (orientation && ~orientation_d) begin
                            aim_angle_nxt = 8'd0;
                        end else if (~orientation && orientation_d) begin
                            aim_angle_nxt = 8'd128;
                        end
                    end
                    state_nxt = START_CALC;
                end
            end

            START_CALC: begin
                start_calc_nxt = 1'b1;
                state_nxt = WAIT_CALC;
            end

            WAIT_CALC: begin
                start_calc_nxt = 1'b0;
                state_nxt = calc_done ? OUTPUT_VALUE : WAIT_CALC;
            end

            OUTPUT_VALUE : begin
                x_out_nxt = x_pos + x_aim - X_OFFSET;
                y_out_nxt = y_pos + y_aim - Y_OFFSET;
                state_nxt = IDLE;
            end
            
            default: begin
                state_nxt = IDLE;
            end
            
        endcase
    end        

endmodule
