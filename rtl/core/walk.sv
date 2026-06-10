/*
 * Designed by MP
 * 
 * How it works:
 * Moves worm according to the input and checks for worm collisions.
 */

module walk #(
    parameter SPEED          = 10,
    parameter GRAVITY        = 4,
    parameter TERRAIN_WIDTH  = 1024,
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

    input  logic [7:0]  collisions,
    input  logic        detector_done,
    output logic        start_check,
    output logic [10:0] detector_pos_x,
    output logic [10:0] detector_pos_y,

    output logic [10:0] pos_x,
    output logic [10:0] pos_y
);
    
    typedef enum logic [2:0] {
        IDLE,
        CHECK_FALL,
        WAIT_FALL,
        EVALUATE_FALL,
        CHECK_MOVE,
        WAIT_MOVE,
        EVALUATE,
        DONE
    } state_t;
    
    state_t state, state_nxt;
    
    logic initialized, initialized_nxt;

    logic [10:0] pos_x_nxt, pos_y_nxt;
    logic [10:0] target_x, target_x_nxt;
    logic [10:0] target_y, target_y_nxt;
    logic [10:0] detector_pos_x_nxt, detector_pos_y_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pos_x          <= '0;
            pos_y          <= '0;
            target_x       <= '0;
            target_y       <= '0;
            detector_pos_x <= '0;
            detector_pos_y <= '0;
            state          <= IDLE;
            initialized    <= 1'b0;
        end else begin
            pos_x          <= pos_x_nxt;
            pos_y          <= pos_y_nxt;
            target_x       <= target_x_nxt;
            target_y       <= target_y_nxt;
            detector_pos_x <= detector_pos_x_nxt;
            detector_pos_y <= detector_pos_y_nxt;
            state          <= state_nxt;
            initialized    <= initialized_nxt;
        end
    end

    always_comb begin
        pos_x_nxt          = pos_x;
        pos_y_nxt          = pos_y;
        target_x_nxt       = target_x;
        target_y_nxt       = target_y;
        detector_pos_x_nxt = detector_pos_x;
        detector_pos_y_nxt = detector_pos_y;
        state_nxt          = state;
        start_check        = 1'b0;
        initialized_nxt    = initialized;

        if (!initialized && enable) begin
            pos_x_nxt = pos_x_init;
            pos_y_nxt = pos_y_init;
            initialized_nxt = 1'b1;
        end

        case(state)
            IDLE: begin
                if (enable && initialized && sync) begin
                    target_x_nxt = pos_x;
                    target_y_nxt = pos_y;
                    state_nxt    = CHECK_FALL;
                end
            end

            CHECK_FALL: begin
                detector_pos_x_nxt = target_x;
                detector_pos_y_nxt = target_y;
                start_check        = 1'b1;
                state_nxt          = WAIT_FALL;
            end

            WAIT_FALL: begin
                if (detector_done) begin
                    state_nxt = EVALUATE_FALL;
                end
            end

            EVALUATE_FALL: begin
                if (!collisions[2] && !collisions[3] && !collisions[4]) begin
                    // Path underneath is completely empty -> Apply Gravity
                    if ((pos_y + GRAVITY) < TERRAIN_HEIGHT) begin
                        pos_y_nxt    = pos_y + GRAVITY;
                        target_y_nxt = pos_y + GRAVITY;
                        state_nxt    = CHECK_FALL;
                    end else begin
                        pos_y_nxt    = TERRAIN_HEIGHT - 1;
                        state_nxt    = DONE;
                    end
                end else begin
                    if (left || right) begin
                        if (left) begin
                            target_x_nxt = (pos_x >= SPEED) ? (pos_x - SPEED) : 0;
                        end else begin
                            target_x_nxt = ((pos_x + SPEED) < TERRAIN_WIDTH) ? (pos_x + SPEED) : (TERRAIN_WIDTH - 1);
                        end
                        target_y_nxt = pos_y;
                        state_nxt    = CHECK_MOVE;
                    end else begin
                        state_nxt = DONE;
                    end
                end
            end

            CHECK_MOVE: begin
                detector_pos_x_nxt = target_x;
                detector_pos_y_nxt = target_y;
                start_check        = 1'b1; 
                state_nxt          = WAIT_MOVE;
            end

            WAIT_MOVE: begin
                if (detector_done) begin
                    state_nxt = EVALUATE;
                end
            end

            EVALUATE: begin
                if (left && (collisions[0] || collisions[1] || collisions[2])) begin
                    if (target_y > 4 && !collisions[7]) begin
                        target_y_nxt = target_y - 4; 
                        state_nxt    = CHECK_MOVE;
                    end else begin
                        state_nxt = DONE;
                    end
                end 
                else if (right && (collisions[4] || collisions[5] || collisions[6])) begin
                    if (target_y > 4 && !collisions[7]) begin
                        target_y_nxt = target_y - 4;
                        state_nxt    = CHECK_MOVE;
                    end else begin
                        state_nxt = DONE;
                    end
                end 
                else begin
                    pos_x_nxt = target_x;
                    pos_y_nxt = target_y;
                    state_nxt = DONE;
                end
            end

            DONE: begin
                state_nxt = IDLE;
            end

            default: state_nxt = IDLE;
        endcase
    end

endmodule
