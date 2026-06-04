/*
 * Designed by MP
 * 
 * How it works:
 * Deletes terrain where explosion occurs using a filled Midpoint Circle Algorithm.
 */

module terrain_destruction #(
    parameter TERRAIN_WIDTH  = 1024,
    parameter TERRAIN_HEIGHT = 768,
    parameter RAM_DELAY      = 2
)(
    input  logic clk,
    input  logic rst_n,

    input  logic start,

    input  logic [10:0] pos_x,
    input  logic [10:0] pos_y,

    input  logic [7:0]  radius,

    output logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] ram_address,
    output logic ram_clr,

    output logic done
);

    typedef enum logic [1:0] {
        IDLE, 
        CALC_POINT,
        FILLING,
        FINISH
    } state_t;
    
    state_t state, state_nxt;

    logic [10:0] x_i, x_i_nxt;
    logic [10:0] y_i, y_i_nxt;
    logic signed [11:0] p, p_nxt;

    logic [1:0] segment, segment_nxt;
    logic signed [11:0] fill_start, fill_start_nxt;
    logic signed [11:0] fill_end, fill_end_nxt;
    logic signed [11:0] fill_cur, fill_cur_nxt;
    logic signed [11:0] current_row, current_row_nxt;

    logic [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] ram_address_nxt;
    logic ram_clr_nxt;
    logic done_nxt;

    logic ram_clr_pipe [RAM_DELAY-1:0];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            ram_address  <= '0;
            ram_clr      <= '0;
            done         <= '0;
            x_i          <= '0;
            y_i          <= '0;
            p            <= '0;
            segment      <= '0;
            fill_start   <= '0;
            fill_end     <= '0;
            fill_cur     <= '0;
            current_row  <= '0;

            for (int i = 0; i < RAM_DELAY; i++) begin
                ram_clr_pipe[i]  <= '0;
            end
        end else begin
            state        <= state_nxt;
            ram_address  <= ram_address_nxt;
            done         <= done_nxt;
            x_i          <= x_i_nxt;
            y_i          <= y_i_nxt;
            p            <= p_nxt;
            segment      <= segment_nxt;
            fill_start   <= fill_start_nxt;
            fill_end     <= fill_end_nxt;
            fill_cur     <= fill_cur_nxt;
            current_row  <= current_row_nxt;

            ram_clr_pipe[0] <= ram_clr_nxt;
            for (int i = 1; i < RAM_DELAY; i++) begin
                ram_clr_pipe[i]  <= ram_clr_pipe[i-1];
            end

            ram_clr <= ram_clr_pipe[RAM_DELAY-1];
        end        
    end

    always_comb begin
        state_nxt        = state;
        done_nxt         = 1'b0;
        ram_address_nxt  = ram_address;
        ram_clr_nxt     = 1'b0;
        
        x_i_nxt          = x_i;
        y_i_nxt          = y_i;
        p_nxt            = p;
        
        segment_nxt      = segment;
        fill_start_nxt   = fill_start;
        fill_end_nxt     = fill_end;
        fill_cur_nxt     = fill_cur;
        current_row_nxt  = current_row;

        case (state)
            
            IDLE: begin
                ram_address_nxt = '0;
                done_nxt        = 1'b0;
                x_i_nxt         = '0;
                y_i_nxt         = radius;
                p_nxt           = $signed(1) - $signed({4'b0, radius});
                segment_nxt     = 2'b00;
                
                if (start) begin
                    state_nxt = CALC_POINT;
                end
            end
            
            CALC_POINT: begin
                if (x_i <= y_i) begin
                    state_nxt       = FILLING;
                    segment_nxt     = 2'b00;
                    current_row_nxt = $signed({1'b0, pos_y}) + $signed({1'b0, y_i});
                    fill_start_nxt  = $signed({1'b0, pos_x}) - $signed({1'b0, x_i});
                    fill_end_nxt    = $signed({1'b0, pos_x}) + $signed({1'b0, x_i});
                    fill_cur_nxt    = $signed({1'b0, pos_x}) - $signed({1'b0, x_i});
                end else begin
                    state_nxt       = FINISH;
                end
            end
            
            FILLING: begin
                if (current_row >= 0 && current_row < TERRAIN_HEIGHT && 
                    fill_cur >= 0 && fill_cur < TERRAIN_WIDTH) begin
                    ram_address_nxt = (current_row * TERRAIN_WIDTH) + fill_cur;
                    ram_clr_nxt    = 1'b1;
                end else begin
                    ram_clr_nxt    = 1'b0;
                end

                if (fill_cur < fill_end) begin
                    fill_cur_nxt = fill_cur + 1;
                end else begin
                    if (segment == 2'b00) begin
                        segment_nxt     = 2'b01;
                        current_row_nxt = $signed({1'b0, pos_y}) - $signed({1'b0, y_i});
                        fill_start_nxt  = $signed({1'b0, pos_x}) - $signed({1'b0, x_i});
                        fill_end_nxt    = $signed({1'b0, pos_x}) + $signed({1'b0, x_i});
                        fill_cur_nxt    = $signed({1'b0, pos_x}) - $signed({1'b0, x_i});
                    end else if (segment == 2'b01) begin
                        segment_nxt     = 2'b10;
                        current_row_nxt = $signed({1'b0, pos_y}) + $signed({1'b0, x_i});
                        fill_start_nxt  = $signed({1'b0, pos_x}) - $signed({1'b0, y_i});
                        fill_end_nxt    = $signed({1'b0, pos_x}) + $signed({1'b0, y_i});
                        fill_cur_nxt    = $signed({1'b0, pos_x}) - $signed({1'b0, y_i});
                    end else if (segment == 2'b10) begin
                        segment_nxt     = 2'b11;
                        current_row_nxt = $signed({1'b0, pos_y}) - $signed({1'b0, x_i});
                        fill_start_nxt  = $signed({1'b0, pos_x}) - $signed({1'b0, y_i});
                        fill_end_nxt    = $signed({1'b0, pos_x}) + $signed({1'b0, y_i});
                        fill_cur_nxt    = $signed({1'b0, pos_x}) - $signed({1'b0, y_i});
                    end else if (segment == 2'b11) begin
                        x_i_nxt = x_i + 1;
                        if (p < 0) begin
                            p_nxt = p + $signed({1'b0, (x_i_nxt << 1)}) + 1;
                        end else begin
                            y_i_nxt = y_i - 1;
                            p_nxt   = p + $signed({1'b0, (x_i_nxt << 1)}) - $signed({1'b0, (y_i_nxt << 1)}) + 1;
                        end
                        state_nxt = CALC_POINT;
                    end
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