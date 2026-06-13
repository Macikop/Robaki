/*
 * Designed by MP
 * 
 * How it works:
 * Decides how bullet should move
 */

module bullet #(
    parameter GRAVITY = 10,
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,
    input  logic sync,

    input  logic enable,

    input  logic signed [7:0] wind,
    input  logic [7:0] aim_angle,
    input  logic [7:0] shot_power,

    input  logic [10:0] worm_pos_x,
    input  logic [10:0] worm_pos_y,

    input  logic signed [7:0] x_component,
    input  logic signed [7:0] y_component,
    input  logic conv_done,

    output logic conv_start,
    output logic [7:0] conv_phi,
    output logic [7:0] conv_length,

    output logic start_exposion,
    memory_if.out ram_client,

    output logic enable_draw,
    output logic [10:0] pos_x,
    output logic [10:0] pos_y

);

    logic cd_start, cd_done;
    logic cd_hit;

    assign conv_length = shot_power;
    assign conv_phi = aim_angle;

    edge_detector #(
        .POSITIVE(1'b1)
    ) u_edge_detector (
        .clk,
        .rst_n,
        .din           (enable),
        .edge_detected (conv_start)
    );

    physics_engine #(
        .GRAVITY    (GRAVITY),
        .MAP_WIDTH  (TERRAIN_WIDTH),
        .MAP_HEIGHT (TERRAIN_HEIGHT)
    ) u_physics_engine (
        .clk,
        .rst_n,
        .sync,
        .start           (enable && conv_done),
        .wind            (wind),
        .velocity_x_init (x_component),
        .velocity_y_init (y_component),
        .pos_x_init      (worm_pos_x),
        .pos_y_init      (worm_pos_y),
        .cd_hit          ({8{cd_hit}}),
        .cd_done         (cd_done),
        .cd_start        (cd_start),
        .done            (start_exposion),
        .pos_x           (pos_x),
        .pos_y           (pos_y)
    );

    simple_collision_detector #(
        .RAM_DELAY      (2),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT)
    ) u_simple_collision_detector (
        .clk,
        .rst_n,
        .pos_x       (pos_x),
        .pos_y       (pos_y),
        .start       (cd_start),
        .ram_client  (ram_client),
        .collision   (cd_hit),
        .done        (cd_done)
    );

endmodule