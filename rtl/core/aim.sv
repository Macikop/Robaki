/*
 * Designed by MP
 * 
 * How it works:
 * Gets up and down key and outputs position of aim marker (and aim_angle to bullet).
 */

module aim #(
    parameter logic [7:0] AIM_DISTACNE = 50,
    parameter logic [10:0] X_OFFSET = 16,
    parameter logic [10:0] Y_OFFSET = 16
)(
    input  logic clk,
    input  logic rst_n,
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
    output logic [10:0] y_out,
    input  logic enable
);

    typedef enum logic [1:0] {
        IDLE,
        START_CALC,
        WAIT_CALC
    } state_t;

    state_t state, state_nxt;

    logic [10:0] x_out_nxt, y_out_nxt;
    logic [7:0] aim_angle_nxt; 
    logic orientation_last;
    logic start_calc_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            x_out            <= '0;
            y_out            <= '0;
            aim_angle        <= 8'd0; 
            orientation_last <= 1'b0;
            state            <= IDLE;
            length           <= '0;
            start_calc       <= '0;
        end else begin
            x_out            <= x_out_nxt;
            y_out            <= y_out_nxt;
            aim_angle        <= aim_angle_nxt;
            orientation_last <= orientation;
            state            <= state_nxt;
            length           <= AIM_DISTACNE;
            start_calc       <= start_calc_nxt;
        end
    end

    always_comb begin
        state_nxt      = state;
        aim_angle_nxt  = aim_angle;
        x_out_nxt      = x_out;
        y_out_nxt      = y_out;
        start_calc_nxt = start_calc;

        if(enable && sync) begin
            if(orientation && ~orientation_last) begin
                if (aim_angle > 8'd64 && aim_angle < 8'd192) begin
                    aim_angle_nxt = 8'd0; 
                end
            end else if (~orientation && orientation_last) begin
                if (aim_angle <= 8'd64 || aim_angle >= 8'd192) begin
                    aim_angle_nxt = 8'd128; 
                end
            end
            
            if(up) begin
                if (orientation) begin
                    if (aim_angle == 8'd0) begin
                        aim_angle_nxt = 8'd255;
                    end else if (aim_angle > 8'd192 || aim_angle <= 8'd64) begin
                        aim_angle_nxt = aim_angle - 8'd1;   
                    end
                end else begin
                    if (aim_angle < 8'd192) begin
                        aim_angle_nxt = aim_angle + 8'd1;
                    end
                end
            end else if (down) begin
                if (orientation) begin
                    if (aim_angle < 8'd64 || aim_angle >= 8'd192) begin
                        aim_angle_nxt = aim_angle + 8'd1;
                    end
                end else begin
                    if (aim_angle > 8'd64) begin 
                        aim_angle_nxt = aim_angle - 8'd1;
                    end
                end
            end
        end

        case (state)
            IDLE: begin
                if (enable && sync) begin
                    state_nxt = START_CALC;
                end
            end

            START_CALC: begin
                if (enable) begin
                    start_calc_nxt = 1'b1;
                    state_nxt  = WAIT_CALC;
                end else begin
                    state_nxt  = IDLE;
                end
            end

            WAIT_CALC: begin
                if (!enable) begin
                    state_nxt = IDLE;
                end else if (calc_done) begin
                    x_out_nxt = x_pos + $unsigned({{3{x_aim[7]}}, x_aim}) - X_OFFSET;
                    y_out_nxt = y_pos + $unsigned({{3{y_aim[7]}}, y_aim}) - Y_OFFSET;
                    state_nxt = IDLE;
                end
            end

            default: state_nxt = IDLE;
        endcase
    end

endmodule
