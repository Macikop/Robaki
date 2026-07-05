/*
 * Designed by MP
 * 
 * How it works:
 * Top module of core. Just the whole game.
 */

module top_core #(
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768,
    parameter WORM_WIDTH = 32,
    parameter WORM_HEIGHT = 32,
    parameter GRAVITY = 10
) (
    input  logic clk,
    input  logic rst_n,
    input  logic vsync,

    input  logic space,
    input  logic up,
    input  logic down,
    input  logic left,
    input  logic right,

    input  logic ram_value,
    output logic [$clog2(TERRAIN_WIDTH * TERRAIN_WIDTH)-1:0] ram_address,
    output logic ram_clear,

    output logic        draw_worms,

    output logic [10:0] draw_worm_0_x_pos,
    output logic [10:0] draw_worm_0_y_pos,
    output logic        draw_worm_0_orientation,
    output logic [10:0] draw_worm_1_x_pos,
    output logic [10:0] draw_worm_1_y_pos,
    output logic        draw_worm_1_orientation,

    output logic [10:0] aim_x_pos,
    output logic [10:0] aim_y_pos,
    output logic        aim_en,

    output logic [10:0] draw_bullet_x,
    output logic [10:0] draw_bullet_y,
    output logic        draw_bullet_en,

    output logic [10:0] draw_explosion_x,
    output logic [10:0] draw_explosion_y,
    output logic [10:0] draw_explosion_radius,
    output logic        draw_explosion_en,
    output logic [11:0] draw_explosion_color,

    output logic        draw_logo,
    output logic        draw_end

);

    localparam WRITE_CHANNEL = 0;
    localparam RAM_DELAY = 2;
    localparam RAM_CHANNELS = 6;

    logic sync;

    logic [7:0] sine_val;
    logic [7:0] sine_addr;

    logic start_screen_en, walking_en, shooting_en, bullet_en, explosion_en, end_screen_en;
    logic capture_wind;

    logic [7:0] wind;

    logic impact;
    logic explosion_done;
    logic explosion_end;
    logic [7:0] explosion_radius;
    logic clear;

    logic explosion_done_worm[0:1];

    logic [7:0] shot_power;
    logic [7:0] aim_angle;
    logic [7:0] aim_length;
    logic calc_done;
    logic start_calc;

    logic [10:0] bullet_x, bullet_y;
    logic current_player;
    logic current_worm_direction;

    logic [6:0] worm_health [0:1];

    logic [10:0] current_worm_x_pos, current_worm_y_pos;
    logic [10:0] worm_0_x_pos, worm_1_x_pos;
    logic [10:0] worm_0_y_pos, worm_1_y_pos;
    logic worm_0_direction, worm_1_direction;

    logic worm_ground_hit [0:1];

    logic conv_done;
    logic conv_start;
    logic [7:0] conv_phi;
    logic [7:0] conv_length;
    logic signed [7:0] x_component;
    logic signed [7:0] y_component;

    logic polar_done;

    logic [7:0] x_component_bullet, y_component_bullet;
    logic [7:0] x_aim, y_aim;

    memory_if ram_clients[0:RAM_CHANNELS-1]();

    assign draw_logo = start_screen_en;
    assign draw_end = end_screen_en;

    assign current_worm_x_pos = current_player ? worm_0_x_pos : worm_1_x_pos;
    assign current_worm_y_pos = current_player ? worm_0_y_pos : worm_1_y_pos;
    assign current_worm_direction = current_player ? worm_0_direction : worm_1_direction;

    assign draw_worms              = walking_en || shooting_en || bullet_en || explosion_en;
    assign draw_worm_0_x_pos       = worm_0_x_pos;
    assign draw_worm_0_y_pos       = worm_0_y_pos;
    assign draw_worm_0_orientation = worm_0_direction;
    
    assign draw_worm_1_x_pos       = worm_1_x_pos;
    assign draw_worm_1_y_pos       = worm_1_y_pos;
    assign draw_worm_1_orientation = worm_1_direction;

    sr_flip_flop #(
        .PRIORITY ("RESET")
    ) u_sr_flip_flop (
        .clk,
        .rst_n,
        .s     (explosion_done_worm[0] && explosion_done_worm[1] && explosion_done),
        .r     (!explosion_en),
        .q     (explosion_end)
    );

    master_fsm u_master_fsm (
        .clk,
        .rst_n,
        .space_bar       (space),
        .vsync_in        (vsync),
        .worm_health     (worm_health),
        .worms_on_ground (worm_ground_hit),

        .bullet_impact   (impact),
        .explosion_done  (explosion_end),
        .sync_out        (sync),
        .start_screen_en (start_screen_en),
        .walking_en      (walking_en),
        .shooting_en     (shooting_en),
        .bullet_en       (bullet_en),
        .explosion_en    (explosion_en),
        .end_screen_en   (end_screen_en),
        .capture_wind    (capture_wind),
        .current_player  (current_player)
    );

    rng #(
        .OUTPUT_WIDTH (8),
        .SEED         (32'hACE1),
        .SPREAD       (32'h5555_5555)
    ) u_rng (
        .clk,
        .rst_n,
        .capture       (capture_wind),
        .random_number (wind)
    );

    tdc #(
        .MAX_TIME (255)
    ) u_tdc (
        .clk,
        .rst_n,
        .sync,
        .enable (shooting_en),
        .pulse  (space),
        .value  (shot_power), 
        .done   ()
    );

    aim #(
        .AIM_DISTACNE (50),
        .X_OFFSET     (WORM_WIDTH / 2),
        .Y_OFFSET     (WORM_WIDTH / 2)
    ) u_aim (
        .clk,
        .rst_n,
        .sync,
        .enable      (walking_en || shooting_en),
        .up          (up),
        .down        (down),
        .start_calc  (start_calc),
        .calc_done   (calc_done),
        .x_aim       (x_aim),
        .y_aim       (y_aim),
        .x_pos       (current_worm_x_pos),
        .y_pos       (current_worm_y_pos),
        .orientation (current_worm_direction),
        .aim_angle   (aim_angle),
        .length      (aim_length),
        .x_out       (aim_x_pos),
        .y_out       (aim_y_pos)
    );
    
    assign aim_en = walking_en || shooting_en;

    bullet #(
        .GRAVITY        (GRAVITY),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT)
    ) u_bullet (
        .clk,
        .rst_n,
        .sync,
        .enable         (bullet_en),
        .wind           (wind),
        .aim_angle      (aim_angle),
        .shot_power     (shot_power),
        .worm_pos_x     (current_worm_x_pos),
        .worm_pos_y     (current_worm_y_pos),
        .x_component    (x_component_bullet),
        .y_component    (y_component_bullet),
        .conv_done      (conv_done),
        .conv_start     (conv_start),
        .conv_phi       (conv_phi),
        .conv_length    (conv_length),
        .start_exposion (impact),
        .enable_draw    (draw_bullet_en),
        .pos_x          (bullet_x),
        .pos_y          (bullet_y),
        .ram_client     (ram_clients[0])
    );

    assign draw_bullet_x = bullet_x;
    assign draw_bullet_y = bullet_y;

    polar_to_cartesian u_polar_to_cartesian (
        .clk,
        .rst_n,
        .start       (bullet_en ? conv_start : start_calc),
        .phi         (bullet_en ? conv_phi : aim_angle),
        .length      (bullet_en ? conv_length : aim_length),
        .lut_value   (sine_val),
        .lut_address (sine_addr),
        .x_component (x_component),
        .y_component (y_component),
        .done        (polar_done)
    );

    assign conv_done = bullet_en ? polar_done : 1'b0;
    assign calc_done = bullet_en ? 1'b0 : polar_done;

    assign x_component_bullet = bullet_en ? x_component : 8'b0;
    assign y_component_bullet = bullet_en ? y_component : 8'b0; 

    assign x_aim = bullet_en ? 8'b0 : x_component;
    assign y_aim = bullet_en ? 8'b0 : y_component;

    sine_lut u_sine_lut(
        .clk,
        .rst_n,
        .addr(sine_addr),
        .value(sine_val)
    );

    explosion #(
        .RADIUS         (8'd100),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT)
    ) u_explosion (
        .clk,
        .rst_n,
        .enable               (explosion_en),
        .sync,
        .explosion_x          (bullet_x),
        .explosion_y          (bullet_y),
        .explosion_done       (explosion_done),
        .explosion_radius     (explosion_radius),
        .draw_explosion_x     (draw_explosion_x),
        .draw_explosion_y     (draw_explosion_y),
        .draw_explosion_r     (draw_explosion_radius),
        .draw_explosion_en    (draw_explosion_en),
        .draw_explosion_color (draw_explosion_color),
        .terrain_ram          (ram_clients[1]),
        .ram_clear            (clear)
    );

    ram_address_mux #(
        .ADDRESS_WIDTH($clog2(TERRAIN_HEIGHT * TERRAIN_WIDTH)),
        .WORD_WIDTH(1),
        .INPUTS_NUMBER(RAM_CHANNELS),
        .WRITE_CHANNEL(WRITE_CHANNEL),
        .RAM_DELAY(RAM_DELAY)
    ) u_ram_address_mux (
        .clk,
        .rst_n,
        .clients        (ram_clients),
        .clear          (clear),
        .ram_value      (ram_value),
        .ram_address    (ram_address),
        .ram_clear      (ram_clear)
    );

    worm #(
        .WORM_WIDTH     (WORM_WIDTH),
        .WORM_HEIGHT    (WORM_HEIGHT),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .GRAVITY        (GRAVITY)
    ) u_worm_0 (
        .clk,
        .rst_n,
        .active_turn      (current_player),
        .sync,
        .explosion_x      (bullet_x),
        .explosion_y      (bullet_y),
        .explosion_radius (explosion_radius),
        .walking_en       (walking_en),
        .explosion_en     (explosion_en),
        .left             (left),
        .right            (right),
        .wind             (wind),
        .walk_ram         (ram_clients[2]),
        .physics_ram      (ram_clients[3]),
        .explosion_done   (explosion_done_worm[0]),
        .pos_x            (worm_0_x_pos),
        .pos_y            (worm_0_y_pos),
        .direction        (worm_0_direction),
        .worm_hp          (worm_health[0]),
        .worm_hit         (worm_ground_hit[0])
    );

    worm #(
        .WORM_WIDTH     (WORM_WIDTH),
        .WORM_HEIGHT    (WORM_HEIGHT),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .GRAVITY        (GRAVITY)
    ) u_worm_1 (
        .clk,
        .rst_n,
        .active_turn      (!current_player),
        .sync,
        .explosion_x      (bullet_x),
        .explosion_y      (bullet_y),
        .explosion_radius (explosion_radius),
        .walking_en       (walking_en),
        .explosion_en     (explosion_en),
        .left             (left),
        .right            (right),
        .wind             (wind),
        .walk_ram         (ram_clients[4]),
        .physics_ram      (ram_clients[5]),
        .explosion_done   (explosion_done_worm[1]),
        .pos_x            (worm_1_x_pos),
        .pos_y            (worm_1_y_pos),
        .direction        (worm_1_direction),
        .worm_hp          (worm_health[1]),
        .worm_hit         (worm_ground_hit[1])
    );

endmodule