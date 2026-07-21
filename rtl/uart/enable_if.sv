

interface enable_if();

    logic   start_screen_en;
    logic   end_screen_en;
    logic   draw_worms;
    logic   aim_en;
    logic   draw_bullet_en;
    logic   draw_explosion_en;

    modport in(
        input start_screen_en,
        input end_screen_en,
        input draw_worms,
        input aim_en,
        input draw_bullet_en,
        input draw_explosion_en
    );

    modport out(
        output start_screen_en,
        output end_screen_en,
        output draw_worms,
        output aim_en,
        output draw_bullet_en,
        output draw_explosion_en
    );

endinterface