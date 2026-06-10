/*
 * Designed by MP
 * 
 * How it works:
 * Top module of core. Just the whole game.
 */

module top_core (
    input  logic clk,
    input  logic rst_n,
    
    input  logic vsync

    //keyboard interface,
    

);

    logic sync;

    logic [7:0] sine_val;
    logic [7:0] sine_addr;

    master_fsm u_master_fsm (
        .clk,
        .rst_n,
        .space_bar       (),
        .vsync_in        (vsync),
        .worm_health     (),
        .worms_on_ground (),
        .bullet_impact   (),
        .explosion_done  (),
        .sync_out        (sync),
        .start_screen_en (),
        .walking_en      (),
        .shooting_en     (),
        .bullet_en       (),
        .explosion_en    (),
        .end_screen_en   (),
        .capture_wind    ()
    );

    rng #(
        .OUTPUT_WIDTH (),
        .SEED         (),
        .SPREAD       ()
    ) u_rng (
        .clk,
        .rst_n,
        .capture       (),
        .random_number ()
    );

    tdc #(
        .MAX_TIME ()
    ) u_tdc (
        .clk,
        .rst_n,
        .sync,
        .enable (),
        .pulse  (),
        .value  (),
        .done   ()
    );

    aim #(
        .AIM_DISTACNE (),
        .X_OFFSET     (),
        .Y_OFFSET     ()
    ) u_aim (
        .clk,
        .rst_n,
        .sync,
        .up          (),
        .down        (),
        .start_calc  (),
        .calc_done   (),
        .x_aim       (),
        .y_aim       (),
        .x_pos       (),
        .y_pos       (),
        .orientation (),
        .aim_angle   (),
        .length      (),
        .x_out       (),
        .y_out       (),
        .enable      ()
    );
    
    bullet #(
        .GRAVITY        (),
        .TERRAIN_WIDTH  (),
        .TERRAIN_HEIGHT ()
    ) u_bullet (
        .clk,
        .rst_n,
        .sync,
        .enable         (),
        .wind           (),
        .aim_angle      (),
        .shot_power     (),
        .worm_pos_x     (),
        .worm_pos_y     (),
        .x_component    (),
        .y_component    (),
        .conv_done      (),
        .conv_start     (),
        .conv_phi       (),
        .conv_length    (),
        .start_exposion (),
        .enable_draw    (),
        .pos_x          (),
        .pos_y          (),
        .ram_client     ()
    );

    polar_to_cartesian u_polar_to_cartesian (
        .clk         (),
        .rst_n       (),
        .start       (),
        .phi         (),
        .length      (),
        .lut_value   (sine_val),
        .lut_address (sine_addr),
        .x_component (),
        .y_component (),
        .done        ()
    );

    sine_lut u_sine_lut(
        .clk,
        .rst_n,

        .addr(sine_addr),
        .value(sine_val)
    );

    explosion #(
        .RADIUS         (),
        .TERRAIN_WIDTH  (),
        .TERRAIN_HEIGHT ()
    ) u_explosion (
        .clk,
        .rst_n,
        .enable           (),
        .sync,
        .expolsion_x      (),
        .explosion_y      (),
        .explosion_done   (),
        .explosion_radius (),
        .terrain_ram      ()
    );


endmodule