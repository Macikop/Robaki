/*  Designed by KS
 *  
 *  Top module connecting 4-byte UART module with decoder, packet slicer and encoder.
 *  
 *  Takes player parameters and sends them as 4-byte packets through standard UART Tx line
 * 
 *  Updates player parameters based on received 4-byte packets
 */

module top_game_uart(
    input logic clk,
    input logic rst_n,
    input logic vsync,

    input logic [3:0] current_state_tx,
    input logic current_player_tx,
    input logic [10:0] worm_1_xpos_tx,
    input logic [10:0] worm_1_ypos_tx,
    input logic [7:0] aim_angle_tx,
    input logic [7:0] shot_power_tx,
    input logic [10:0] bullet_x_tx,
    input logic [10:0] bullet_y_tx,
    input logic [7:0] explosion_radius_tx,
    input logic [6:0] worm_1_health_tx,

    input logic rx,

    output logic [3:0] current_state_rx,
    output logic current_player_rx,
    output logic [10:0] worm_1_xpos_rx,
    output logic [10:0] worm_1_ypos_rx,
    output logic [7:0] aim_angle_rx,
    output logic [7:0] shot_power_rx,
    output logic [10:0] bullet_x_rx,
    output logic [10:0] bullet_y_rx,
    output logic [7:0] explosion_radius_rx,
    output logic [6:0] worm_1_health_rx,

    output logic tx,
    output logic done_tx,
    output logic empty,

    output logic start_screen_en,
    output logic end_screen_en,
    output logic draw_worms,
    output logic aim_en,
    output logic draw_bullet_en,
    output logic draw_explosion_en
    );

    timeunit 1ns;
    timeprecision 1ps;

    logic[5:0] enables;

    wire [31:0] tx_packet;
    wire [31:0] rx_packet;
    wire start;
    wire done;

    assign done_tx = done;

    //enables
    assign start_screen_en = enables[0];
    assign end_screen_en = enables[1];
    assign draw_worms = enables[2];
    assign aim_en = enables[3];
    assign draw_bullet_en = enables[4];
    assign draw_explosion_en = enables[5];

top_4byte_uart u_top_4byte_uart(
        .clk,
        .rst_n,
        .start(start),
        .data_transmit(tx_packet),
        .rx,
        .done(done),
        .data_received(rx_packet),
        .tx,
        .empty
    );

    game_uart_encoder u_game_uart_encoder(
        .clk,
        .rst_n,
        .vsync,
        .current_state(current_state_tx),
        .current_player(current_player_tx),
        .worm_1_xpos(worm_1_xpos_tx),
        .worm_1_ypos(worm_1_ypos_tx),
        .aim_angle(aim_angle_tx),
        .shot_power(shot_power_tx),
        .bullet_x(bullet_x_tx),
        .bullet_y(bullet_y_tx),
        .explosion_radius(explosion_radius_tx),
        .worm_1_health(worm_1_health_tx),
        .data32_out(tx_packet),
        .start(start)
    );

    wire [3:0] current_state_slicer;
    wire current_player_slicer;
    wire [2:0] extra_slicer;
    wire [23:0] payload_slicer;

    uart_packet_slicer u_uart_packet_slicer(
        .clk,
        .rst_n,
        .done(done),
        .packet(rx_packet),
        .current_state(current_state_slicer),
        .current_player(current_player_slicer),
        .extra(extra_slicer),
        .payload(payload_slicer)
    );

    game_uart_decoder u_game_uart_decoder(
        .clk,
        .rst_n,
        .current_state_in(current_state_slicer),
        .current_player_in(current_player_slicer),
        .payload(payload_slicer),
        .current_player(current_player_rx),
        .worm_1_xpos(worm_1_xpos_rx),
        .worm_1_ypos(worm_1_ypos_rx),
        .aim_angle(aim_angle_rx),
        .shot_power(shot_power_rx),
        .bullet_x(bullet_x_rx),
        .bullet_y(bullet_y_rx),
        .explosion_radius(explosion_radius_rx),
        .worm_1_health(worm_1_health_rx),
        .current_state(current_state_rx),
        .enable_out(enables)
    );

endmodule