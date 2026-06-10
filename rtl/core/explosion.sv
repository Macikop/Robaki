/*
 * Designed by MP
 * 
 * How it works:
 * 
 */

module explosion #(
    parameter logic [7:0] RADIUS = 50,
    parameter logic TERRAIN_WIDTH = 1024,
    parameter logic TERRAIN_HEIGHT = 768
)(
    input  logic clk,
    input  logic rst_n,

    input  logic enable,
    input  logic sync,

    input  logic [10:0] expolsion_x,
    input  logic [10:0] explosion_y,

    output logic explosion_done,
    output logic [7:0] explosion_radius,

    memory_if.out terrain_ram
);

//TODO: make explosion animation using circles

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
        .start  (start_explosion),
        .pos_x  (expolsion_x),
        .pos_y  (expolsion_y),
        .radius (RADIUS),
        .v_ram  (terrain_ram),
        .done   (explosion_done)
    );


endmodule