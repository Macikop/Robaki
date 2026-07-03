/*
 * Designed by MP
 * 
 * How it works:
 * Top project module
 */

module top_game (
    input  logic clk_core,
    input  logic clk_media,
    /* may be usefull
     * input logic clk_uart,
     * input logic clk_keyboard,
     */ 

    input  logic rst_n,

    /* not yet ready 
     * 
     * input logic uart_rx
     * output logic uart_tx
     * 
     * input logic ps2_data,
     * input logic ps2_clk,
     */

    /* temporary switch interface */
    input  logic up,
    input  logic down,
    input  logic right,
    input  logic left,
    input  logic space,

    /* audio interface */
    // input  logic mute_in,
    // input  logic volume_in,
    
    // output logic audio,
    // output logic shoutdone,
    // output logic gain,

    /* vga interface */
    output logic [3:0] r,
    output logic [3:0] g,
    output logic [3:0] b,
    output logic vs,
    output logic hs
);
    localparam TERRAIN_WIDTH = 1024;
    localparam TERRAIN_HEIGHT = 768;
    
    localparam WORM_WIDTH = 32;
    localparam WORM_HEIGHT = 32;
    
    localparam GRAVITY = 10;

    logic sync;
    logic [$clog2(TERRAIN_HEIGHT * TERRAIN_WIDTH)-1:0] ram_address_core, ram_address_vga;
    logic ram_value_core, ram_clear_core, ram_value_vga;

    logic [10:0] draw_worm_0_x_pos_core;
    logic [10:0] draw_worm_0_y_pos_core;
    logic draw_worm_0_orientation_core;
    logic [10:0] draw_worm_1_x_pos_core;
    logic [10:0] draw_worm_1_y_pos_core;
    logic draw_worm_1_orientation_core;
    logic [10:0]aim_x_pos_core;
    logic [10:0]aim_y_pos_core;
    logic aim_en_core;
    logic [10:0] draw_bullet_x_core;
    logic [10:0] draw_bullet_y_core;
    logic draw_bullet_en_core;
    logic [10:0] draw_explosion_x_core;
    logic [10:0] draw_explosion_y_core;
    logic [10:0] draw_explosion_radius_core;
    logic draw_explosion_en_core;

    logic draw_worms;
    logic [10:0] draw_worm_0_x_pos;
    logic [10:0] draw_worm_0_y_pos;
    logic draw_worm_0_orientation;
    logic [10:0] draw_worm_1_x_pos;
    logic [10:0] draw_worm_1_y_pos;
    logic draw_worm_1_orientation;
    logic [10:0]aim_x_pos;
    logic [10:0]aim_y_pos;
    logic aim_en;
    logic [10:0] draw_bullet_x;
    logic [10:0] draw_bullet_y;
    logic draw_bullet_en;
    logic [10:0] draw_explosion_x;
    logic [10:0] draw_expolsion_y;
    logic [10:0] draw_explosion_radius;
    logic draw_explosion_en;
    logic [11:0] draw_explosion_color;
    logic start_screen_en, end_screen_en;

    
    top_core #(
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .WORM_WIDTH     (WORM_WIDTH),
        .WORM_HEIGHT    (WORM_HEIGHT),
        .GRAVITY        (GRAVITY)
    ) u_top_core (
        .clk                     (clk_core),
        .rst_n                   (rst_n),
        .vsync                   (sync),
        .space                   (space),
        .up                      (up),
        .down                    (down),
        .left                    (left),
        .right                   (right),
        .ram_value               (ram_value_core),
        .ram_address             (ram_address_core),
        .ram_clear               (ram_clear_core),
        .draw_worms              (draw_worms),
        .draw_worm_0_x_pos       (draw_worm_0_x_pos_core),
        .draw_worm_0_y_pos       (draw_worm_0_y_pos_core),
        .draw_worm_0_orientation (draw_worm_0_orientation_core),
        .draw_worm_1_x_pos       (draw_worm_1_x_pos_core),
        .draw_worm_1_y_pos       (draw_worm_1_y_pos_core),
        .draw_worm_1_orientation (draw_worm_1_orientation_core),
        .aim_x_pos               (aim_x_pos_core),
        .aim_y_pos               (aim_y_pos_core),
        .aim_en                  (aim_en_core),
        .draw_bullet_x           (draw_bullet_x_core),
        .draw_bullet_y           (draw_bullet_y_core),
        .draw_bullet_en          (draw_bullet_en_core),
        .draw_explosion_x        (draw_explosion_x_core),
        .draw_explosion_y        (draw_explosion_y_core),
        .draw_explosion_radius   (draw_explosion_radius_core),
        .draw_explosion_en       (draw_explosion_en_core),
        .draw_explosion_color    (draw_explosion_color),
        .draw_logo               (start_screen_en),
        .draw_end                (end_screen_en)
    );

    cdc #(
        .STAGES (2),
        .WIDTH  (137)
    ) u_cdc (
        .clk_a     (clk_core),
        .clk_b     (clk_media),
        .rst_n     (rst_n),
        .data_in   ({draw_worm_0_x_pos_core, draw_worm_0_y_pos_core, draw_worm_0_orientation_core, draw_worm_1_x_pos_core, draw_worm_1_x_pos_core, draw_worm_1_y_pos_core, draw_worm_1_orientation_core, aim_x_pos_core, aim_y_pos_core, aim_en_core, draw_bullet_x_core, draw_bullet_y_core, draw_bullet_en_core, draw_explosion_x_core, draw_explosion_y_core, draw_explosion_radius_core, draw_explosion_en_core}),
        .send_data (sync),
        .data_out  ({draw_worm_0_x_pos, draw_worm_0_y_pos, draw_worm_0_orientation, draw_worm_1_x_pos, draw_worm_1_x_pos, draw_worm_1_y_pos, draw_worm_1_orientation, aim_x_pos, aim_y_pos, aim_en, draw_bullet_x, draw_bullet_y, draw_bullet_en, draw_explosion_x, draw_expolsion_y, draw_explosion_radius, draw_explosion_en})
    );

    cdc #(
        .STAGES (2),
        .WIDTH  (1)
    ) u_cdc_vsync (
        .clk_a     (clk_media),
        .clk_b     (clk_core),
        .rst_n     (rst_n),
        .data_in   (vs),
        .send_data (vs),
        .data_out  (sync)
    );

    terrain_ram #(
        .WIDTH             (TERRAIN_WIDTH),
        .HEIGHT            (TERRAIN_HEIGHT),
        .TERRAIN_FILE_PATH ()
    ) u_terrain_ram (
        .clk_vga       (clk_media),
        .clk_core      (clk_core),
        .rst_n         (rst_n),
        .address_vga   (ram_address_vga),
        .address_core  (ram_address_core),
        .clear         (ram_clear_core),
        .data_out_vga  (ram_value_vga),
        .data_out_core (ram_value_core)
    );

    top_vga #(
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .SPRITE_WIDTH   (WORM_WIDTH),
        .SPRITE_HEIGHT  (WORM_HEIGHT)
    ) u_top_vga (
        .clk                     (clk_media),
        .rst_n                   (rst_n),
        .start_screen_en         (start_screen_en),
        .draw_worms              (draw_worms),
        .end_screen_en           (end_screen_en),
        .draw_worm_0_x_pos       (draw_worm_0_x_pos),
        .draw_worm_0_y_pos       (draw_worm_0_y_pos),
        .draw_worm_0_orientation (draw_worm_0_orientation),
        .draw_worm_1_x_pos       (draw_worm_1_x_pos),
        .draw_worm_1_y_pos       (draw_worm_1_y_pos),
        .draw_worm_1_orientation (draw_worm_1_orientation),
        .aim_x_pos               (aim_x_pos),
        .aim_y_pos               (aim_y_pos),
        .aim_en                  (aim_en),
        .draw_bullet_x           (draw_bullet_x),
        .draw_bullet_y           (draw_bullet_y),
        .draw_bullet_en          (draw_bullet_en),
        .draw_explosion_x        (draw_explosion_x),
        .draw_expolsion_y        (draw_expolsion_y),
        .draw_explosion_radius   (draw_explosion_radius),
        .draw_explosion_en       (draw_explosion_en),
        .draw_explosion_color    (draw_explosion_color),
        .terrain_present         (ram_value_vga),
        .address_terrain         (ram_address_vga),
        .vs                      (vs),
        .hs                      (hs),
        .r                       (r),
        .g                       (g),
        .b                       (b)
    );

    // top_audio_driver #(
    //     .FILE_SIZE (14),
    //     .FILE_PATH ("../../rtl/audio_driver/music_files/nokia_ringtone.hex")
    // ) u_top_audio_driver (
    //     .clk       (clk_media),
    //     .rst_n     (rst_n),
    //     .mute      (mute_in),
    //     .volume    (volume_in),
    //     .wave_out  (audio),
    //     .gain      (gain),
    //     .shoutdown (shoutdown)
    // );



endmodule