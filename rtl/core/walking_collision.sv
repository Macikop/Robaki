/*
 * Designed by MP
 * 
 * How it works:
 * Checs for collisions for walking module.
 * Colisions 0 - 7 are inside the worm in the corrners and on the sides, 
 * colliders 8 - 20 outside the worm, used to decide if move is possible.
 * module assumes 32 x 32 px worm
 * 
 *      [ 0] - [ 7] - [ 6]
 *       |             |
 *      [ 1]          [ 5]   
 * [ 8]  |             |   [20]
 * [ 9]  |             |   [19]
 * [10]  |             |   [18]
 * [11]  |             |   [17]
 * [12] [ 2] - [ 3] - [ 4] [16]
 *      [13] - [14] - [15]
 * 
 * 
 */

module walking_collision #(
    parameter RAM_DELAY      = 2,
    parameter TERRAIN_WIDTH  = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [10:0] pos_x,
    input  logic [10:0] pos_y,
    input  logic start,
    
    memory_if.out ram_client,
    output logic [20:0] collisions,
    output logic done
);

    localparam WIDTH = 32;
    localparam HEIGHT = 32;

    localparam NUM_POINTS = 21;
    localparam ADDR_W = $clog2(TERRAIN_HEIGHT * TERRAIN_WIDTH);

    typedef enum logic [1:0] {
        IDLE,
        RUNNING,
        FINISH
    } state_t;

    state_t state, state_nxt;

    logic [4:0] requests_sent,      requests_sent_nxt;
    logic [4:0] responses_received, responses_received_nxt;

    logic [20:0] collisions_nxt;
    logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] terrain_address_nxt;
    logic              ram_request_nxt;
    logic              done_nxt;

    logic [4:0] idx_pipe     [0:RAM_DELAY-1];
    logic [4:0] idx_pipe_nxt [0:RAM_DELAY-1];

    logic valid_pipe     [0:RAM_DELAY-1];
    logic valid_pipe_nxt [0:RAM_DELAY-1];

    logic signed [11:0] points_x [0:NUM_POINTS-1];
    logic signed [11:0] points_y [0:NUM_POINTS-1];

    initial begin
        points_x = '{
            // Main Box: [0] to [7]
            0, 0, 0, WIDTH/2, WIDTH, WIDTH, WIDTH, WIDTH/2,
            // Left Column: [8] to [12] (Top down to Bottom)
            -1, -1, -1, -1, -1,
            // Bottom Row: [13] to [15] (Left to Right)
            0, WIDTH/2, WIDTH,
            // Right Column: [16] to [20] (Bottom up to Top)
            WIDTH + 1, WIDTH + 1, WIDTH + 1, WIDTH + 1, WIDTH + 1
        };

        points_y = '{
            // Main Box: [0] to [7]
            0, HEIGHT/2, HEIGHT, HEIGHT, HEIGHT, HEIGHT/2, 0, 0,
            // Left Column: [8] to [12] (Assuming it aligns near the bottom half)
            HEIGHT - 4, HEIGHT - 3, HEIGHT - 2, HEIGHT - 1, HEIGHT,
            // Bottom Row: [13] to [15]
            HEIGHT + 1, HEIGHT + 1, HEIGHT + 1,
            // Right Column: [16] to [20] (Matching your diagram layout going up)
            HEIGHT, HEIGHT - 1, HEIGHT - 2, HEIGHT - 3, HEIGHT - 4
        };
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state              <= IDLE;
            requests_sent      <= '0;
            responses_received <= '0;
            collisions         <= '0;
            done               <= 1'b0;

            ram_client.addresses <= '0;
            ram_client.request   <= 1'b0;

            for(int i = 0; i < RAM_DELAY; i++) begin
                idx_pipe[i]   <= '0;
                valid_pipe[i] <= 1'b0;
            end
        end
        else begin
            state              <= state_nxt;
            requests_sent      <= requests_sent_nxt;
            responses_received <= responses_received_nxt;
            collisions         <= collisions_nxt;
            done               <= done_nxt;

            ram_client.addresses <= terrain_address_nxt;
            ram_client.request   <= ram_request_nxt;

            for(int i = 0; i < RAM_DELAY; i++) begin
                idx_pipe[i]   <= idx_pipe_nxt[i];
                valid_pipe[i] <= valid_pipe_nxt[i];
            end
        end
    end

    always_comb begin
        state_nxt              = state;
        requests_sent_nxt      = requests_sent;
        responses_received_nxt = responses_received;
        terrain_address_nxt    = ram_client.addresses;
        ram_request_nxt        = ram_client.request;
        collisions_nxt         = collisions;
        done_nxt               = done;

        for(int j = 1; j < RAM_DELAY; j++) begin
            idx_pipe_nxt[j]   = idx_pipe[j-1];
            valid_pipe_nxt[j] = valid_pipe[j-1];
        end

        idx_pipe_nxt[0]   = '0;
        valid_pipe_nxt[0] = 1'b0;

        if(valid_pipe[RAM_DELAY-1]) begin
            collisions_nxt[idx_pipe[RAM_DELAY-1]] = ram_client.value;
            responses_received_nxt = responses_received + 1;
        end

        case(state)

            IDLE: begin
                done_nxt               = 1'b0;
                collisions_nxt         = '0;
                requests_sent_nxt      = 0;
                responses_received_nxt = 0;
                
                if (start) begin
                    terrain_address_nxt = ADDR_W'(($signed({1'b0, pos_y}) + points_y[0]) * TERRAIN_WIDTH + ($signed({1'b0, pos_x}) + points_x[0]));
                    ram_request_nxt     = 1'b1;
                    state_nxt           = RUNNING;
                end else begin
                    ram_request_nxt     = 1'b0;
                    state_nxt           = IDLE;
                end
            end

            RUNNING: begin
                ram_request_nxt = 1'b1;

                if (ram_client.request && ram_client.granted) begin
                    idx_pipe_nxt[0]   = requests_sent;
                    valid_pipe_nxt[0] = 1'b1;

                    requests_sent_nxt = requests_sent + 5'd1;
                    ram_request_nxt = 1'b0;
                    
                    if (requests_sent + 1 < NUM_POINTS) begin
                        terrain_address_nxt = ADDR_W'(($signed({1'b0, pos_y}) + points_y[requests_sent + 5'd1]) * TERRAIN_WIDTH + ($signed({1'b0, pos_x}) + points_x[requests_sent + 5'd1]));
                    end
                end else begin
                    idx_pipe_nxt[0] = '0;
                    valid_pipe_nxt[0] = 1'b0;
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
