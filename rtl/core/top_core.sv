/*
 * Designed by MP
 * 
 * How it works:
 * Top module of core. Just the whole game.
 */

module top_core (
    input  logic clk,
    input  logic rst_n,
    
    input  logic vsync,

    //keyboard interface,
    

);

    logic sync;

    master_fsm u_master_fsm (
        .clk,
        .rst_n,
        .space_bar       (),
        .vsync_in        (vsync),
        .worm_healt      (),
        .worms_on_ground (),
        .bullet_impact   (),
        .exposion_done   (),
        .sync_out        (sync),
        .start_screen_en (),
        .walking_en      (),
        .shooting_en     (),
        .bullet_en       (),
        .expolosion_en   (),
        .end_screen_en   (),
        .capture_wind    ()
    );


endmodule