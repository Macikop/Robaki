/*
 * Designed by MP
 * 
 * How it works:
 * Checks colision with terrain. 
 * Check is performed on specific points - each side and each corner, according to this pattern.
 * 
 * [0]--[7]--[6]
 *  |         |
 * [1]       [5]
 *  |         |
 * [2]--[3]--[4]
 * 
 */

module collision_detector #(
    parameter WIDTH          = 32,
    parameter HEIGHT         = 32,
    parameter RAM_DELAY      = 2,
    parameter TERRAIN_WIDTH  = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [10:0] pos_x,
    input  logic [10:0] pos_y,
    input  logic start_check,

    input  logic is_occupied,
    input  logic granted,
    output logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] terrain_address,
    output logic ram_request,
    
    output logic [7:0] collisions,
    output logic done
);

    localparam NUM_POINTS = 8;

    typedef enum logic [1:0] {
        IDLE,
        RUNNING,
        FINISH
    } state_t;

    state_t state, state_nxt;

    logic [3:0] requests_sent,      requests_sent_nxt;
    logic [3:0] responses_received, responses_received_nxt;

    logic [7:0] colisions_nxt;
    logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] terrain_address_nxt;
    logic       ram_request_nxt;
    logic       done_nxt;

    logic [2:0] idx_pipe     [0:RAM_DELAY-1];
    logic [2:0] idx_pipe_nxt [0:RAM_DELAY-1];

    logic valid_pipe     [0:RAM_DELAY-1];
    logic valid_pipe_nxt [0:RAM_DELAY-1];

    logic [11:0] points_x [0:NUM_POINTS-1];
    logic [11:0] points_y [0:NUM_POINTS-1];

    integer i, j;

    initial begin
        points_x = '{
            0,
            0,
            0,
            WIDTH/2,
            WIDTH,
            WIDTH,
            WIDTH,
            WIDTH/2
        };

        points_y = '{
            0,
            HEIGHT/2,
            HEIGHT,
            HEIGHT,
            HEIGHT,
            HEIGHT/2,
            0,
            0
        };
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            requests_sent <= '0;
            responses_received <= '0;
            terrain_address <= '0;
            ram_request <= 1'b0;
            collisions <= '0;
            done <= 1'b0;

            for(i = 0; i < RAM_DELAY; i++) begin
                idx_pipe[i] <= '0;
                valid_pipe[i] <= 1'b0;
            end
        end
        else begin
            state <= state_nxt;
            requests_sent <= requests_sent_nxt;
            responses_received <= responses_received_nxt;
            terrain_address <= terrain_address_nxt;
            ram_request <= ram_request_nxt;
            collisions <= colisions_nxt;
            done <= done_nxt;

            for(i = 0; i < RAM_DELAY; i++) begin
                idx_pipe[i] <= idx_pipe_nxt[i];
                valid_pipe[i] <= valid_pipe_nxt[i];
            end
        end
    end

    always_comb begin
        state_nxt = state;
        requests_sent_nxt = requests_sent;
        responses_received_nxt = responses_received;
        terrain_address_nxt = terrain_address;
        ram_request_nxt = ram_request;
        colisions_nxt = collisions;
        done_nxt = done;

        for(j = 1; j < RAM_DELAY; j++) begin
            idx_pipe_nxt[j]   = idx_pipe[j-1];
            valid_pipe_nxt[j] = valid_pipe[j-1];
        end
        idx_pipe_nxt[0]   = '0;
        valid_pipe_nxt[0] = 1'b0;

        if(valid_pipe[RAM_DELAY-1]) begin
            colisions_nxt[idx_pipe[RAM_DELAY-1]] = is_occupied;
            responses_received_nxt = responses_received + 1;
        end

        case(state)

            IDLE: begin
                done_nxt = 1'b0;
                colisions_nxt = '0;
                requests_sent_nxt = 0;
                responses_received_nxt = 0;
                
                if (start_check) begin
                    terrain_address_nxt = (pos_y + points_y[0]) * TERRAIN_WIDTH + (pos_x + points_x[0]);
                    ram_request_nxt = 1'b1;
                    state_nxt = RUNNING;
                end else begin
                    ram_request_nxt = 1'b0;
                    state_nxt = IDLE;
                end
            end

            RUNNING: begin
                if (ram_request && granted) begin
                    idx_pipe_nxt[0] = requests_sent[2:0];
                    valid_pipe_nxt[0] = 1'b1;
                    
                    if (requests_sent + 1 < NUM_POINTS) begin
                        requests_sent_nxt = requests_sent + 1;
                        terrain_address_nxt = (pos_y + points_y[requests_sent_nxt[2:0]]) * TERRAIN_WIDTH + (pos_x + points_x[requests_sent_nxt[2:0]]);
                        ram_request_nxt = 1'b1;
                    end else begin
                        requests_sent_nxt = requests_sent + 1;
                        ram_request_nxt = 1'b0;
                    end
                end

                if (responses_received_nxt == NUM_POINTS) begin
                    state_nxt = FINISH;
                end else begin
                    state_nxt = RUNNING;
                end
            end

            FINISH: begin
                done_nxt  = 1'b1;
                state_nxt = IDLE;
            end

            default: begin
                state_nxt = IDLE;    
            end

        endcase
    end

endmodule
