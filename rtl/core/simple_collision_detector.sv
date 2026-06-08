/*
 * Designed by MP
 * 
 * How it works:
 * Checks if collision is detected in current point
 */

module simple_collision_detector #(
    parameter RAM_DELAY = 2,
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic [10:0] pos_x,
    input  logic [10:0] pos_y,

    input  logic start,

    input  logic is_occupied,
    input  logic ram_granted,
    output logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] ram_address,
    output logic ram_request,

    output logic collision,
    output logic done    
);

    typedef enum logic [1:0] {
        IDLE,
        RUNNING,
        FINISH
    } state_t;

    state_t state, state_nxt;

    logic collision_nxt;
    logic [$clog2(TERRAIN_WIDTH*TERRAIN_HEIGHT)-1:0] ram_address_nxt;
    logic done_nxt;
    logic ram_request_nxt;

    logic valid_pipe     [0:RAM_DELAY-1];
    logic valid_pipe_nxt [0:RAM_DELAY-1];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            ram_address <= '0;
            ram_request <= 1'b0;
            collision   <= 1'b0;
            done        <= 1'b0;

            for (int i = 0; i < RAM_DELAY; i++) begin
                valid_pipe[i] <= 1'b0;
            end
        end
        else begin
            state       <= state_nxt;
            ram_address <= ram_address_nxt;
            ram_request <= ram_request_nxt;
            collision   <= collision_nxt;
            done        <= done_nxt;

            for (int i = 0; i < RAM_DELAY; i++) begin
                valid_pipe[i] <= valid_pipe_nxt[i];
            end
        end
    end

    always_comb begin
        state_nxt       = state;
        ram_address_nxt = ram_address;
        ram_request_nxt = ram_request;
        collision_nxt   = collision;
        done_nxt        = done;

        for (int j = 1; j < RAM_DELAY; j++) begin
            valid_pipe_nxt[j] = valid_pipe[j-1];
        end
        valid_pipe_nxt[0] = 1'b0;

        case (state)
            IDLE: begin
                done_nxt = 1'b0;
                collision_nxt = 1'b0;

                if (start) begin
                    ram_address_nxt = (pos_y * TERRAIN_WIDTH) + pos_x;
                    ram_request_nxt = 1'b1; // Drop request into the pool
                    state_nxt = RUNNING;
                end
            end

            RUNNING: begin
                if (ram_request && ram_granted) begin
                    valid_pipe_nxt[0] = 1'b1;
                    ram_request_nxt   = 1'b0; // Turn off request once accepted
                end

                if (valid_pipe[RAM_DELAY-1]) begin
                    collision_nxt = is_occupied;
                    state_nxt = FINISH;
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
