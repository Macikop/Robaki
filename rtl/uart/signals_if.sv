

interface signals_if ();

    logic [3:0] current_state_tx;
    logic current_player_tx;
    logic [10:0] worm_1_xpos_tx;
    logic [10:0] worm_1_ypos_tx;
    logic [7:0] aim_angle_tx;
    logic [7:0] shot_power_tx;
    logic [10:0] bullet_x_tx;
    logic [10:0] bullet_y_tx;
    logic [7:0] explosion_radius_tx;
    logic [6:0] worm_1_health_tx;

    modport in(
        input current_state_tx,
        input current_player_tx,
        input worm_1_xpos_tx,
        input worm_1_ypos_tx,
        input aim_angle_tx,
        input shot_power_tx,
        input bullet_x_tx,
        input bullet_y_tx,
        input explosion_radius_tx,
        input worm_1_health_tx
    );

    modport out(
        output current_state_tx,
        output current_player_tx,
        output worm_1_xpos_tx,
        output worm_1_ypos_tx,
        output aim_angle_tx,
        output shot_power_tx,
        output bullet_x_tx,
        output bullet_y_tx,
        output explosion_radius_tx,
        output worm_1_health_tx
    );

endinterface