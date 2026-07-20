/*
 * Designed by MP
 * 
 * How it works:
 * Moves worm according to the input and checks for worm collisions.
 */

module walk #(
    parameter logic signed [10:0] SPEED = 10,
    parameter logic [10:0] GRAVITY = 10,
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic enable,
    input  logic sync,

    input  logic left,
    input  logic right,

    input  logic [10:0] pos_x_init,
    input  logic [10:0] pos_y_init,

    input  logic [20:0] collisions,
    input  logic        detector_done,
    output logic        start_check,
    output logic [10:0] detector_pos_x,
    output logic [10:0] detector_pos_y,

    output logic [10:0] pos_x,
    output logic [10:0] pos_y,

    output logic done
);

    typedef enum logic [2:0] {
        IDLE,
        INIT,
        WAIT_COLLISIONS,
        STEP,
        CHECK_CD,
        FINISH
    } state_t;

    state_t state, state_nxt;

    logic [10:0] pos_x_nxt, pos_y_nxt;

    logic signed [10:0] step_count, step_count_nxt; 
    logic [2:0] step_height, step_height_nxt;

    logic [10:0] detector_pos_x_nxt; 
    logic [10:0] detector_pos_y_nxt;
    logic start_check_nxt;

    logic [10:0] velocity_y, velocity_y_nxt;

    logic is_falling, is_falling_nxt;
    logic direction, direction_nxt;

    logic done_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            velocity_y <= '0;
            step_height <= '0;
            step_count <= '0;
            detector_pos_x <= '0;
            detector_pos_y <= '0;
            start_check <= '0;
            pos_x <= '0;
            pos_y <= '0;
            is_falling <= '0;
            direction <= '0;
            done <= '0;
        end else begin
            state <= state_nxt;
            velocity_y <= velocity_y_nxt;
            step_height <= step_height_nxt;
            step_count <= step_count_nxt;
            detector_pos_x <= detector_pos_x_nxt;
            detector_pos_y <= detector_pos_y_nxt;
            start_check <= start_check_nxt;
            pos_x <= pos_x_nxt;
            pos_y <= pos_y_nxt;
            is_falling <= is_falling_nxt;
            direction <= direction_nxt;
            done <= done_nxt;
        end
    end

    always_comb begin
        state_nxt = state;
        velocity_y_nxt = velocity_y;
        step_height_nxt = step_height; 

        pos_x_nxt = pos_x;
        pos_y_nxt = pos_y;
        detector_pos_x_nxt = detector_pos_x;
        detector_pos_y_nxt = detector_pos_y;
        step_count_nxt = step_count;
        start_check_nxt = 1'b0;
        is_falling_nxt = is_falling;
        direction_nxt = direction;
        done_nxt = 1'b0;

        case (state)

            IDLE : begin
                if (enable && sync) begin
                    state_nxt = INIT;
                end
            end

            INIT: begin
                start_check_nxt = 1'b1;
                pos_x_nxt = pos_x_init;
                pos_y_nxt = pos_y_init;
                detector_pos_x_nxt = pos_x_init;
                detector_pos_y_nxt = pos_y_init;
                step_count_nxt = '0;
                state_nxt = WAIT_COLLISIONS;
            end
            

            WAIT_COLLISIONS : begin
                start_check_nxt = 1'b0;
                if (detector_done) begin
                    if (~|collisions[15:13]) begin
                        velocity_y_nxt = velocity_y + GRAVITY;
                        step_count_nxt = velocity_y + GRAVITY;
                        is_falling_nxt = 1'b1;
                    end else begin
                        velocity_y_nxt = '0;
                        is_falling_nxt = 1'b0;
                        if (right && !left && !collisions[20]) begin
                            step_count_nxt = SPEED;
                            direction_nxt = 1'b1; 
                            step_height_nxt = collisions[16] + collisions[17] + collisions[18] + collisions[19];
                        end else if (!right && left && !collisions[8]) begin
                            step_count_nxt = SPEED;
                            direction_nxt = 1'b0;
                            step_height_nxt = collisions[9] + collisions[10] + collisions[11] + collisions[12];
                        end else begin
                            step_count_nxt = '0;
                        end
                    end
                    state_nxt = STEP;
                end
            end

            STEP : begin  
                if (step_count == 0) begin
                    state_nxt = FINISH;
                end else begin
                    step_count_nxt = step_count - 1;
                    if (is_falling) begin
                        detector_pos_x_nxt = detector_pos_x;
                        detector_pos_y_nxt = detector_pos_y + 10'd1;
                    end else begin
                        if (direction) begin
                            detector_pos_x_nxt = detector_pos_x + 10'd1;
                            detector_pos_y_nxt = detector_pos_y - step_height;
                        end else begin
                            detector_pos_x_nxt = detector_pos_x - 10'd1;
                            detector_pos_y_nxt = detector_pos_y - step_height;
                        end
                    end
                    start_check_nxt = 1'b1;
                    state_nxt = CHECK_CD;
                end
            end

            CHECK_CD : begin  
                start_check_nxt = 1'b0;
                if (detector_done) begin
                    if(is_falling) begin
                        pos_x_nxt = detector_pos_x;
                        pos_y_nxt = detector_pos_y;
                        if (|collisions[15:13]) begin
                            is_falling_nxt = 1'b0;
                            state_nxt = FINISH;
                        end else begin
                            is_falling_nxt = 1'b1;
                            state_nxt = STEP;
                        end
                    end else begin
                        if (~|collisions[7:0]) begin
                            pos_x_nxt = detector_pos_x;
                            pos_y_nxt = detector_pos_y;
                            if (direction) begin
                                if (!collisions[20]) begin
                                    step_height_nxt = collisions[16] + collisions[17] + collisions[18] + collisions[19];
                                    state_nxt = STEP;
                                end else begin
                                    state_nxt = FINISH;
                                end
                            end else begin
                                if (!collisions[8]) begin
                                    step_height_nxt = collisions[9] + collisions[10] + collisions[11] + collisions[12];
                                    state_nxt = STEP;
                                end else begin
                                    state_nxt = FINISH;
                                end
                            end
                        end else begin
                            state_nxt = FINISH;
                        end
                    end
                end
            end

            FINISH : begin
                step_count_nxt = '0;
                state_nxt = IDLE;
                done_nxt = 1'b1;
            end

            default: begin
                state_nxt = IDLE;
            end
            
        endcase

    end

endmodule
