/*
 * Designed by MP
 * 
 * How it works:
 * Decides the game flow
 */

module master_fsm (
    input  logic clk,
    input  logic rst_n,

);

    typedef enum logic [2:0] {
        IDLE, 
        STARTING_SCREEN,
        WALKING,
        SHOOTING,
        FLIGHT,
        EXPLOSION,
        SWITCH_PLAYER
    } state_t;

    state_t state, state_nxt;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state <= IDLE;
        end else begin
            state <= state_nxt;
        end
    end

    always_comb begin

        state_nxt = state;
        
        case (exp)
            IDLE: begin
                
            end

            STARTING_SCREEN: begin
                
            end

            WALKING: begin
                
            end

            SHOOTING: begin
                
            end

            FLIGHT: begin
                
            end
            
            EXPLOSION: begin
                
            end
            
            SWITCH_PLAYER: begin
                
            end
            
            default: begin
                
            end
            
        endcase        
    end

endmodule
