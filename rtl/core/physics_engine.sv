/*
 * Designed by MP 
 * 
 * How it works:
 * Moves object and applies wind and gravity to it. 
 * Object stops moving when it hits terrain (cd_hit) or map border.
 */

module physics_engine #(
    parameter GRAVITY = 10,
    parameter MAP_WIDTH = 1024,
    parameter MAP_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic sync,
    input  logic start,

    input  logic signed [7:0] wind,
    input  logic signed [7:0] velocity_x_init,
    input  logic signed [7:0] velocity_y_init,

    input  logic cd_hit,
    input  logic cd_done,

    output logic cd_start,

    output logic done,
    output logic [10:0] pos_x,
    output logic [10:0] pos_y
);

    typedef enum logic [2:0] {
        IDLE,
        INIT,
        STEP,
        WAIT_CD,
        WAIT_SYNC,
        FINISH
    } state_t;

    state_t state, state_nxt;

    // Registered Positions and Velocities
    logic signed [10:0] x, y;
    logic signed [10:0] x_nxt, y_nxt;
    logic signed [10:0] vx, vy;
    logic signed [10:0] vx_nxt, vy_nxt;

    // Registers for storing Bresenham variables across cycles safely
    logic signed [11:0] dx, dy;
    logic signed [11:0] dx_nxt, dy_nxt;
    logic signed [11:0] D, D_nxt;
    logic signed [1:0]  xi, xi_nxt;
    logic signed [1:0]  yi, yi_nxt;
    
    // Step counting tracking registers
    logic [11:0] step_count, step_count_nxt;
    logic is_steep, is_steep_nxt;

    logic done_nxt;

    // Sequential Block
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= IDLE;
            x           <= 0;
            y           <= 0;
            vx          <= 0;
            vy          <= 0;
            pos_x       <= 0;
            pos_y       <= 0;
            dx          <= 0;
            dy          <= 0;
            D           <= 0;
            xi          <= 1;
            yi          <= 1;
            step_count  <= 0;
            is_steep    <= 0;
            done        <= 0;
        end else begin
            state       <= state_nxt;
            x           <= x_nxt;
            y           <= y_nxt;
            vx          <= vx_nxt;
            vy          <= vy_nxt;
            pos_x       <= x_nxt;
            pos_y       <= y_nxt;
            dx          <= dx_nxt;
            dy          <= dy_nxt;
            D           <= D_nxt;
            xi          <= xi_nxt;
            yi          <= yi_nxt;
            step_count  <= step_count_nxt;
            is_steep    <= is_steep_nxt;
            done        <= done_nxt;
        end
    end

    // Combinational Logic
    always_comb begin
        // Default assignments to prevent latches
        state_nxt      = state;
        x_nxt          = x;
        y_nxt          = y;
        vx_nxt         = vx;
        vy_nxt         = vy;
        dx_nxt         = dx;
        dy_nxt         = dy;
        D_nxt          = D;
        xi_nxt         = xi;
        yi_nxt         = yi;
        step_count_nxt = step_count;
        is_steep_nxt   = is_steep;
        
        done_nxt       = 1'b0;
        cd_start       = 1'b0;

        case (state)

            IDLE: begin
                if (start && sync) begin
                    vx_nxt    = $signed({{3{velocity_x_init[7]}}, velocity_x_init});
                    vy_nxt    = $signed({{3{velocity_y_init[7]}}, velocity_y_init});
                    state_nxt = INIT;
                end
            end

            INIT: begin
                // Local absolute calculations
                automatic logic signed [11:0] abs_dx = (vx >= 0) ? vx : -vx;
                automatic logic signed [11:0] abs_dy = (vy >= 0) ? vy : -vy;

                xi_nxt = (vx < 0) ? -1 : 1;
                yi_nxt = (vy < 0) ? -1 : 1;

                if (abs_dx >= abs_dy) begin
                    is_steep_nxt   = 1'b0;
                    dx_nxt         = abs_dx;
                    dy_nxt         = abs_dy;
                    step_count_nxt = abs_dx;
                    D_nxt          = (abs_dy << 1) - abs_dx;
                end else begin
                    is_steep_nxt   = 1'b1;
                    dx_nxt         = abs_dy; // Swap delta configurations
                    dy_nxt         = abs_dx;
                    step_count_nxt = abs_dy;
                    D_nxt          = (abs_dx << 1) - abs_dy;
                end

                state_nxt = STEP;
            end

            STEP: begin
                // Check if step processing is required or done
                if (step_count == 0) begin
                    state_nxt = WAIT_SYNC;
                end else begin
                    // General Generalized Bresenham Step Logic
                    if (is_steep) begin
                        y_nxt = y + yi;
                        if (D > 0) begin
                            x_nxt = x + xi;
                            D_nxt = D + ((dy - dx) << 1);
                        end else begin
                            D_nxt = D + (dy << 1);
                        end
                    end else begin
                        x_nxt = x + xi;
                        if (D > 0) begin
                            y_nxt = y + yi;
                            D_nxt = D + ((dy - dx) << 1);
                        end else begin
                            D_nxt = D + (dy << 1);
                        end
                    end

                    step_count_nxt = step_count - 1;
                    cd_start       = 1'b1;
                    state_nxt      = WAIT_CD;
                end
            end

            WAIT_CD: begin
                if (cd_done) begin
                    // Check map boundaries or a collision detector trigger hit
                    if (cd_hit || x < 0 || x >= MAP_WIDTH || y < 0 || y >= MAP_HEIGHT) begin
                        state_nxt = FINISH;
                    end else begin
                        state_nxt = STEP;
                    end
                end
            end

            WAIT_SYNC: begin
                if (sync) begin
                    vx_nxt    = vx + $signed({{3{wind[7]}}, wind});
                    vy_nxt    = vy + GRAVITY;
                    state_nxt = INIT;
                end
            end

            FINISH: begin
                done_nxt  = 1'b1;
                state_nxt = IDLE;
            end

            default: state_nxt = IDLE;
        endcase
    end

endmodule