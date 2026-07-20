/*
 * Designed by MP
 * 
 * How it works:
 * It allows to move worm, and applies damage when hit.
 */

module worm #(
    parameter WORM_WIDTH = 32,
    parameter WORM_HEIGHT = 32,
    parameter TERRAIN_WIDTH = 1024,
    parameter TERRAIN_HEIGHT = 768,
    parameter GRAVITY = 10,
    parameter RAM_DELAY = 2,
    parameter logic [10:0] INIT_X = 11'd100,
    parameter logic [10:0] INIT_Y = 11'd100 
)(
    input  logic clk,
    input  logic rst_n,

    input  logic active_turn,           /* activates whole module */

    input  logic sync,                  /* goes to every internal module that needs it */

    input  logic [10:0] explosion_x,
    input  logic [10:0] explosion_y,
    input  logic [7:0]  explosion_radius,


    input  logic walking_en,            /* Asserted ONLY during WALKING state */
    input  logic explosion_en,          /* Asserted during EXPLOSION (and physics) state */

    /* keyboard inputs */
    input  logic left,
    input  logic right,

    input  logic [7:0] wind,

    memory_if.out physics_ram,          /* Interface for terrain ram */
    memory_if.out walk_ram,

    output logic explosion_done,

    output logic [10:0] pos_x,          /* goes into display and bullet */
    output logic [10:0] pos_y,          /* goes into display and bullet */
    output logic direction,             /* facing left or right */
    output logic [6:0]  worm_hp,        /* tracks current health status for the main FSM to read */

    output logic worm_hit
);

    logic [10:0] r_pos_x, r_pos_y;
    logic [6:0]  r_worm_hp;

    logic cd_start, cd_done, cd_start_walk;
    logic exp_done;
    logic physics_done; 
    logic cd_done_walk;

    logic explosion_consequences_start;
    logic walk_done;

    logic [20:0] walk_collisions;

    logic signed [7:0] velocity_x;
    logic signed [7:0] velocity_y;
    logic [5:0]        exp_damage;

    logic [10:0] pos_x_physics, pos_y_physics;
    logic [10:0] pos_x_walking, pos_y_walking;
    
    logic [7:0]  cd_collisions;
    logic [10:0] cd_pos_x, cd_pos_y;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_pos_x   <= INIT_X;
            r_pos_y   <= INIT_Y;
            direction <= 1'b1;
            r_worm_hp <= 7'd100;
        end else begin
            if (walking_en && walk_done) begin 
                r_pos_x <= pos_x_walking;
                r_pos_y <= pos_y_walking;
            end else if (explosion_en && physics_done) begin
                r_pos_x <= pos_x_physics;
                r_pos_y <= pos_y_physics;
            end

            if (active_turn && walking_en) begin
                if (left) begin
                    direction <= 1'b1;
                end else if (right) begin
                    direction <= 1'b0;
                end
            end

            if (exp_done) begin
                if (exp_damage >= r_worm_hp) begin
                    r_worm_hp <= 7'd0;
                end else begin
                    r_worm_hp <= r_worm_hp - exp_damage;
                end
            end
        end
    end

    assign pos_x = r_pos_x;
    assign pos_y = r_pos_y;
    assign worm_hp = r_worm_hp;
    assign explosion_done = physics_done; 

    sr_flip_flop #(
        .PRIORITY ("RESET")
    ) u_sr_flip_flop (
        .clk,
        .rst_n,
        .s     (physics_done),
        .r     (!explosion_en),
        .q     (worm_hit)
    );

    edge_detector #(
        .POSITIVE (1'b1)
    ) u_edge_detector (
        .clk,
        .rst_n,
        .din           (explosion_en),
        .edge_detected (explosion_consequences_start)
    );

    physics_engine #(
        .GRAVITY(GRAVITY),
        .MAP_WIDTH(TERRAIN_WIDTH),
        .MAP_HEIGHT(TERRAIN_HEIGHT)
    ) u_physics_engine (
        .clk,
        .rst_n,
        .sync,
        .start           (exp_done), 
        .wind            (wind),
        .velocity_x_init (velocity_x),
        .velocity_y_init (velocity_y),
        .pos_x_init      (r_pos_x),
        .pos_y_init      (r_pos_y),
        .cd_hit          (cd_collisions),
        .cd_done         (cd_done),
        .cd_start        (cd_start),
        .done            (physics_done),
        .pos_x           (pos_x_physics),
        .pos_y           (pos_y_physics)
    );

    collision_detector #(
        .WIDTH          (WORM_WIDTH),
        .HEIGHT         (WORM_HEIGHT),
        .RAM_DELAY      (RAM_DELAY),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT)
    ) u_collision_detector (
        .clk         (clk),
        .rst_n       (rst_n),
        .pos_x       (pos_x_physics),
        .pos_y       (pos_y_physics),
        .start_check (cd_start),
        .ram_client  (physics_ram),
        .collisions  (cd_collisions),
        .done        (cd_done)
    );

    explosion_consequences u_explosion_consequences (
        .clk,
        .rst_n,
        .worm_pos_x      (r_pos_x),
        .worm_pos_y      (r_pos_y),
        .explosion_pos_x (explosion_x),
        .explosion_pos_y (explosion_y),
        .explosion_r     ({3'b0, explosion_radius}),
        .start           (explosion_consequences_start),
        .velocity_x      (velocity_x),
        .velocity_y      (velocity_y),
        .damage          (exp_damage),
        .done            (exp_done)
    );

    walk #(
        .SPEED          (11'd1),
        .GRAVITY        (GRAVITY),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT)
    ) u_walk (
        .clk,
        .rst_n,
        .enable          (walking_en && active_turn),
        .sync,
        .left            (left),
        .right           (right),
        .pos_x_init      (r_pos_x), 
        .pos_y_init      (r_pos_y), 
        .start_check     (cd_start_walk),
        .collisions      (walk_collisions),
        .detector_done   (cd_done_walk),
        .detector_pos_x  (cd_pos_x),
        .detector_pos_y  (cd_pos_y),
        .pos_x           (pos_x_walking),
        .pos_y           (pos_y_walking),
        .done            (walk_done)
    );

    walking_collision #(
        .RAM_DELAY      (RAM_DELAY),
        .TERRAIN_WIDTH  (TERRAIN_WIDTH),
        .TERRAIN_HEIGHT (TERRAIN_HEIGHT)
    ) u_walking_collision (
        .clk,
        .rst_n,
        .pos_x      (cd_pos_x),
        .pos_y      (cd_pos_y),
        .start      (cd_start_walk),
        .ram_client (walk_ram),
        .collisions (walk_collisions),
        .done       (cd_done_walk)
    );

endmodule