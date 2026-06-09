/*
 * Designed by MP
 * 
 * How it works:
 * 
 */

module worm #(
    parameter WORM_WIDTH = 32,
    parameter WORM_HEIGHT = 32,

    parameter GRAVITY = 10
)(
    input  logic clk,
    input  logic rst_n,

    input  logic active_turn,           /* activates whole module */

    input  logic sync,                  /* goes to every internal module that needs it */

    input  state_t current_state,

    explosion.in explosion_in,          /* TODO: crerate this interface */

    keyboard.in keyboard_in,            /* TODO: create this interface */

    input  logic [7:0] wind,

    memory.request terrain_ram_conn,    /* Interface for terrain ram */

    output logic [10:0] pos_x,          /* goes into display and bullet */
    output logic [10:0] pos_y,          /* goes into display and bullet */
    output logic direction,             /* facing left or right */
    output logic [7:0] aim_angle        /* goes into polar_to_cartesian and than to aim and bullet */
);

    logic cd_start, cd_done;
    logic [7:0] cd_hit;
    logic exp_done;

    logic signed [7:0] velocity_x;
    logic signed [7:0] velocity_y;


    physics_engine #(
        .GRAVITY(GRAVITY),
        .MAP_WIDTH(1024),
        .MAP_HEIGHT(768)
    ) u_physics_engine (
        .clk,
        .rst_n,

        .sync,
        .start(exp_done),

        .wind(wind),
        .velocity_x_init(velocity_x),
        .velocity_y_init(velocity_y),

        .cd_hit(cd_hit),
        .cd_done(cd_done),
        .cd_start(cd_start),

        .done(),
        .pos_x(pos_x),
        .pos_y(pos_y)

    );

    collision_detector #(
        .WIDTH          (),
        .HEIGHT         (),
        .RAM_DELAY      (),
        .TERRAIN_WIDTH  (),
        .TERRAIN_HEIGHT ()
    ) u_collision_detector (
        .clk             (),
        .rst_n           (),
        .pos_x           (),
        .pos_y           (),
        .start_check     (),
        .is_occupied     (),
        .granted         (),
        .terrain_address (),
        .ram_request     (),
        .collisions      (),
        .done            ()
    );

    explosion_conseqences #(

    ) u_explosion_conseqences (
        .clk,
        .rst_n,

        .worm_pos_x(pos_x),
        .worm_pos_y(pos_y),

        .explosion_pos_x(),
        .explosion_pos_y(),
        .explosion_r(),

        .start(),

        .velocity_x(velocity_x),
        .velocity_y(velocity_y),
        .damage(),

        .done(exp_done)
    );


endmodule
