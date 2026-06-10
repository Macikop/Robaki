/*
 * Designed by MP
 * 
 * How it works:
 * Decides the game flow
 */

//TODO: add so states change on sync

module master_fsm(
    input  logic clk,
    input  logic rst_n,

    input  logic space_bar,
    input  logic vsync_in,

    input  logic [6:0] worm_health [0:1],
    input  logic worms_on_ground [0:1],

    input  logic bullet_impact,
    input  logic explosion_done,

    output logic sync_out,

    output logic start_screen_en,
    output logic walking_en,
    output logic shooting_en,
    output logic bullet_en,
    output logic explosion_en,
    output logic end_screen_en,

    output logic capture_wind
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
    logic space_bar_last;

    logic start_screen_en_nxt;
    logic walking_en_nxt;
    logic shooting_en_nxt;
    logic bullet_en_nxt;
    logic expolosion_en_nxt;
    logic end_screen_en_nxt;
    logic capture_wind_nxt;

    logic posedge_occured, posedge_occured_nxt;
    logic negedge_occured, negedge_occured_nxt;


    always_ff @(posedge clk or negedge rst_n) begin

        if(!rst_n) begin

            state <= STARTING_SCREEN;
            current_player <= '0;

            sync_out <= '0;
            space_bar_last <= 1'b0;

            start_screen_en <= 1'b0;
            walking_en <= 1'b0;
            shooting_en <= 1'b0;
            bullet_en <= 1'b0;
            explosion_en <= 1'b0;
            end_screen_en <= 1'b0;
            capture_wind <= 1'b0;
            posedge_occured <= 1'b0;
            negedge_occured <= 1'b0;


        end else begin

            state <= state_nxt;
            current_player <= current_player_nxt;

            sync_out <= vsync_in;

            space_bar_last <= space_bar;

            start_screen_en <= start_screen_en_nxt;
            walking_en <= walking_en_nxt;
            shooting_en <= shooting_en_nxt;
            bullet_en <= bullet_en_nxt;
            explosion_en <= expolosion_en_nxt;
            end_screen_en <= end_screen_en_nxt;
            
            capture_wind <= capture_wind_nxt;

            posedge_occured <= posedge_occured_nxt;
            negedge_occured <= negedge_occured_nxt;
        end
    end

    always_comb begin

        state_nxt = state;
        current_player_nxt = current_player;

        start_screen_en_nxt = 1'b0;
        walking_en_nxt = 1'b0;
        shooting_en_nxt = 1'b0;
        bullet_en_nxt = 1'b0;
        expolosion_en_nxt = 1'b0;
        end_screen_en_nxt = 1'b0;
        capture_wind_nxt = 1'b0;

        posedge_occured_nxt = posedge_occured;
        negedge_occured_nxt = negedge_occured;

        if(state == WALKING && state_nxt != WALKING) begin
            
        end
        if(state == SHOOTING && state_nxt != SHOOTING) begin
            negedge_occured_nxt = 1'b0;
        end

        if(space_bar && !space_bar_last && ((state == STARTING_SCREEN) || (state == WALKING))) begin
            posedge_occured_nxt = 1'b1;
        end
        if(!space_bar && space_bar_last && (state == SHOOTING)) begin
            negedge_occured_nxt = 1'b1;
        end
        

        case (state)
            STARTING_SCREEN: begin
                if (posedge_occured && vsync_in) begin
                    posedge_occured_nxt = 1'b0;
                    state_nxt = WALKING;
                end else begin
                    state_nxt = STARTING_SCREEN;
                end
                start_screen_en_nxt <= 1'b1;
            end

            WALKING: begin
                if (posedge_occured && vsync_in) begin
                    posedge_occured_nxt = 1'b0;
                    state_nxt = SHOOTING;
                end else begin
                    state_nxt = WALKING;
                end
                walking_en_nxt = 1'b1;
            end

            SHOOTING: begin
                if (negedge_occured && vsync_in) begin
                    negedge_occured_nxt = 1'b0;
                    state_nxt = BULLET_FLIGHT;
                end else begin
                    state_nxt = SHOOTING;
                end
                shooting_en_nxt = 1'b1;
            end

            BULLET_FLIGHT: begin
                state_nxt = (bullet_impact && vsync_in) ? EXPLOSION : BULLET_FLIGHT;
                bullet_en_nxt = 1'b1;
            end
            
            EXPLOSION: begin
                state_nxt = (worms_on_ground[0] && worms_on_ground[1] && explosion_done && vsync_in) ? SWITCH_PLAYER : EXPLOSION;
            end
            
            SWITCH_PLAYER: begin
                current_player_nxt = !current_player;
                state_nxt = (((worm_health[0] == 0) || (worm_health[1] == 0)) && vsync_in) ? END_SCREEN : WALKING;

                capture_wind_nxt = 1'b1;
            end

            END_SCREEN: begin
                end_screen_en_nxt = 1'b1;
                state_nxt = END_SCREEN;     /* Press reset to play again */
            end
            
            default: begin
                state_nxt = STARTING_SCREEN;
            end
            
        endcase        
    end

endmodule
