/*
 * Designed by MP
 * 
 * How it works:
 * Decides the game flow
 */

module master_fsm (
    input  logic clk,
    input  logic rst_n,


    input  logic space_bar,
    input  logic vsync_in,

    output logic vsync_out,
    output logic state_output

);

    typedef enum logic [2:0] {
        STARTING_SCREEN,
        WALKING,
        SHOOTING,
        BULLET_FLIGHT,
        EXPLOSION,
        SWITCH_PLAYER,
        END_SCREEN
    } state_t;

    state_t state, state_nxt;

    logic current_player, current_player_nxt;

    always_ff @(posedge clk or negedge rst_n) begin

        if(!rst_n) begin

            state <= STARTING_SCREEN;
            state_output <= STARTING_SCREEN;
            current_player <= '0;

            vsync_out <= '0;

        end else begin

            state <= state_nxt;
            state_output <= state_nxt;
            current_player <= current_player_nxt;

            vsync_out <= vsync_in;
        end

    end

    always_comb begin

        state_nxt = state;
        current_player_nxt = current_player;
        
        case (state)
            STARTING_SCREEN: begin
                //if posedge on keyboard spacebar -> WALKING
            end

            WALKING: begin
                //if posedge on keyboard spacebar -> SHOOTING
            end

            SHOOTING: begin
                //if negedge on keyboard spacebar -> BULLET_FLIGHT
            end

            BULLET_FLIGHT: begin
                //if terrain_colision -> EXPLOSION
            end
            
            EXPLOSION: begin
                //if both worms have total velocity 0 && explosion ended -> SWITCH_PLAYERS
            end
            
            SWITCH_PLAYER: begin
                current_player_nxt = !current_player;
                state_nxt = WALKING;
                //generate random wind
            end

            END_SCREEN: begin
                //go to this state if any worm have 0hp
            end
            
            default: begin
                
            end
            
        endcase        
    end

endmodule
