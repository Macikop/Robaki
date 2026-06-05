/*
 * Designed by MP
 * 
 * How it works:
 * Calculates X and Y component of the vector according to length and angle
 */

module polar_to_cartesian (
    input  logic clk,
    input  logic rst_n,

    input  logic start,

    input  logic [7:0] phi,

    input  logic [7:0] length,

    input  logic [7:0] lut_value,
    output logic [7:0] lut_address,

    output logic signed [15:0] x_component,
    output logic signed [15:0] y_component,

    output logic done
);
    typedef enum logic [1:0] {
        IDLE, 
        SIN,
        COS,
        FINISH
    } state_t;
    
    state_t state, state_nxt;

    logic [7:0] sin, cos, sin_nxt, cos_nxt;

    logic done_nxt;
    logic signed [15:0] x_component_nxt, y_component_nxt;

    logic [7:0] lut_address_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lut_address <= '0;

            x_component <= '0;
            y_component <= '0;

            done <= '0;

            cos <= '0;
            sin <= '0;

            state <= IDLE;
        end else begin
            lut_address <= lut_address_nxt;

            x_component <= x_component_nxt;
            y_component <= y_component_nxt;

            done <= done_nxt;

            sin <= sin_nxt;
            cos <= cos_nxt;

            state <= state_nxt;
        end
    end

    always_comb begin
        state_nxt       = state;
        lut_address_nxt = lut_address;
        sin_nxt         = sin;
        cos_nxt         = cos;
        x_component_nxt = x_component;
        y_component_nxt = y_component;
        done_nxt        = 1'b0;

        case (state)
            IDLE: begin
                if (start) begin
                    state_nxt       = SIN;
                    lut_address_nxt = phi; 
                end
            end
            
            SIN: begin
                sin_nxt = lut_value; 
                lut_address_nxt = phi + 8'd64; 
                state_nxt       = COS;
            end

            COS: begin
                cos_nxt         = lut_value;
                y_component_nxt = $signed({1'b0, length}) * $signed({1'b0, sin});
                state_nxt       = FINISH;
            end

            FINISH: begin
                x_component_nxt = $signed({1'b0, length}) * $signed({1'b0, cos});
                done_nxt        = 1'b1;
                state_nxt       = IDLE;
            end
            
            default: begin
                state_nxt = IDLE;
            end
        endcase
    end

endmodule
