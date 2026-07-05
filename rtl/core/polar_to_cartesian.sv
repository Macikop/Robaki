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

    (* keep = "true" *)
    output logic signed [7:0] x_component,
    (* keep = "true" *)
    output logic signed [7:0] y_component,

    output logic done
);
    typedef enum logic [2:0] {
        IDLE, 
        SIN,
        COS,
        WAITING,
        FINISH
    } state_t;
    
    state_t state, state_nxt;

    logic signed [8:0] sin, cos, sin_nxt, cos_nxt;

    logic done_nxt;
    logic signed [7:0] x_component_nxt, y_component_nxt;

    logic signed [16:0] mult_x;
    logic signed [16:0] mult_y;

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
                    state_nxt = SIN;
                    lut_address_nxt = phi; 
                end
            end
            
            SIN: begin
                
                lut_address_nxt = phi + 8'd64;
                state_nxt = COS;
            end

            COS: begin
                sin_nxt = $signed({1'b0,lut_value}) - 9'sd127;
                

                state_nxt = WAITING;
            end

            WAITING: begin
                cos_nxt = $signed({1'b0,lut_value}) - 9'sd127;
                state_nxt = FINISH;
            end
            

            FINISH: begin
                mult_x = $signed({1'b0,length}) * cos;
                mult_y = $signed({1'b0,length}) * sin;
                x_component_nxt = mult_x >>> 7;
                y_component_nxt = mult_y >>> 7;

                done_nxt = 1'b1;
                state_nxt = IDLE;
            end
            
            default: begin
                state_nxt = IDLE;
            end
        endcase
    end

endmodule
