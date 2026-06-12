/*
 * Designed by MP
 * 
 * How it works:
 * 
 */

module explosion #(
    parameter logic [7:0] RADIUS = 50,
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic enable,
    input  logic sync,

    input  logic [10:0] explosion_x,
    input  logic [10:0] explosion_y,

    output logic explosion_done,
    output logic [7:0] explosion_radius,

    output logic [10:0] draw_explosion_x,
    output logic [10:0] draw_explosion_y,
    output logic [10:0] draw_explosion_r,
    output logic        draw_explosion_en,
    output logic [11:0] draw_explosion_color,

    output logic ram_clear,
    memory_if.out terrain_ram
);

    logic start_explosion;

    assign explosion_radius = RADIUS; 

    edge_detector #(
        .POSITIVE (1'b1)
    ) u_edge_detector (
        .clk,
        .rst_n,
        .din           (enable),
        .edge_detected (start_explosion)
    );
    
    terrain_destruction #(
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT),
        .RAM_DELAY      (2)
    ) u_terrain_destruction (
        .clk,
        .rst_n,
        .start     (start_explosion),
        .pos_x     (explosion_x),
        .pos_y     (explosion_y),
        .radius    (RADIUS),
        .v_ram     (terrain_ram),
        .ram_clear (ram_clear),
        .done      (explosion_done)
    );

    explosion_effect u_explosion_effect (
        .clk,
        .rst_n,
        .sync,
        .explosion_enable (enable),
        .explosion_x      (explosion_x),
        .explosion_y      (explosion_y),
        .expolsion_radius (RADIUS),
        .draw_enable      (draw_explosion_en),
        .pos_x            (draw_explosion_x),
        .pos_y            (draw_explosion_y),
        .radius           (draw_explosion_r),
        .color            (draw_explosion_color),
        .done             ()
    );

endmodule
