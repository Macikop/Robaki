/*
 * Designed by MP
 * * Description:
 * Testbench for bullet module with integrated Polar to Cartesian hardware and active physics sync generation.
 */

module bullet_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam WIDTH      = 1024;
    localparam HEIGHT     = 768;
    localparam ADDR_WIDTH = $clog2(WIDTH * HEIGHT); // Resolves to 20
    localparam MUX_INPUTS = 3;
    localparam RAM_DELAY  = 2;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    
    // Internal interconnect signals
    logic [ADDR_WIDTH-1:0] mux_to_ram_address;
    logic                  mux_to_ram_clear;
    logic                  raw_ram_data_out;

    // Interface array for the mux
    memory_if mux_client_ifs [0:MUX_INPUTS-1]();

    // Testbench driver signals to stimulate the bullet input ports
    logic        tb_sync;
    logic        tb_enable;
    logic [7:0]  tb_wind;
    logic [7:0]  tb_aim_angle;
    logic [7:0]  tb_shot_power;
    logic [10:0] tb_worm_pos_x;
    logic [10:0] tb_worm_pos_y;

    // Interconnect lines between bullet, polar_to_cartesian, and sine_lut
    logic        p2c_start;
    logic [7:0]  p2c_phi;
    logic [7:0]  p2c_length;
    logic [7:0]  lut_to_p2c_value;
    logic [7:0]  p2c_to_lut_address;
    logic signed [7:0] hw_x_component;
    logic signed [7:0] hw_y_component;
    logic        hw_conv_done;

    // Bullet output monitors
    logic        mon_start_explosion;
    logic        mon_enable_draw;
    logic [10:0] mon_pos_x;
    logic [10:0] mon_pos_y;


    /**
     * Clock generation
     */

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    /**
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end


    /**
     * Dut placement & Helper Hardware
     */

    terrain_ram #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map1.dat")
    ) u_terrain_ram (
        .clk_vga('0),
        .clk_core(clk),
        .rst_n(rst_n),
        .address_vga('0),
        .address_core(mux_to_ram_address), 
        .clear(mux_to_ram_clear),          
        .data_out_vga(),
        .data_out_core(raw_ram_data_out)
    );

    ram_address_mux #(
        .ADDRESS_WIDTH(ADDR_WIDTH),
        .WORD_WIDTH(1),
        .INPUTS_NUMBER(MUX_INPUTS),
        .WRITE_CHANNEL(0),
        .RAM_DELAY(RAM_DELAY)
    ) u_ram_address_mux (
        .clk(clk),
        .rst_n(rst_n),
        .clients(mux_client_ifs),
        .clear('0),
        .ram_value(raw_ram_data_out),
        .ram_address(mux_to_ram_address),
        .ram_clear(mux_to_ram_clear)
    );
    
    bullet #(
        .GRAVITY(10),
        .TERRAIN_WIDTH(WIDTH),
        .TERRAIN_HEIGHT(HEIGHT)
    ) dut (
        .clk (clk),
        .rst_n (rst_n),
        .sync (tb_sync),
        .enable (tb_enable),
        .wind (tb_wind),
        .aim_angle (tb_aim_angle),
        .shot_power (tb_shot_power),
        .worm_pos_x (tb_worm_pos_x),
        .worm_pos_y (tb_worm_pos_y),
        .x_component (hw_x_component), 
        .y_component (hw_y_component), 
        .conv_done (hw_conv_done),     
        .conv_start (p2c_start),       
        .conv_phi (p2c_phi),
        .conv_length (p2c_length),
        .start_exposion (mon_start_explosion),
        .ram_client (mux_client_ifs[0].out),
        .enable_draw (mon_enable_draw),
        .pos_x (mon_pos_x),
        .pos_y (mon_pos_y)
    );

    polar_to_cartesian u_polar_to_cartesian (
        .clk(clk),
        .rst_n(rst_n),
        .start(p2c_start),
        .phi(p2c_phi),
        .length(p2c_length),
        .lut_value(lut_to_p2c_value),
        .lut_address(p2c_to_lut_address),
        .x_component(hw_x_component),
        .y_component(hw_y_component),
        .done(hw_conv_done)
    );

    sine_lut u_sine_lut (
        .clk(clk),
        .rst_n(rst_n),
        .addr(p2c_to_lut_address),
        .value(lut_to_p2c_value)
    );


    /**
     * Loopback/Dummy assignments for unused mux ports to avoid floating lines
     */
    genvar gi;
    generate
        for (gi = 1; gi < MUX_INPUTS; gi++) begin : gen_unused_mux_inputs
            assign mux_client_ifs[gi].addresses = '0;
            assign mux_client_ifs[gi].request   = 1'b0;
        end
    endgenerate 


    /**
     * Tasks and functions
     */

    task automatic init_signals();
        tb_sync         = 1'b0;
        tb_enable       = 1'b0;
        tb_wind         = 8'sd0;
        tb_aim_angle    = 8'd0;
        tb_shot_power   = 8'd0;
        tb_worm_pos_x   = 11'd0;
        tb_worm_pos_y   = 11'd0;
    endtask


    task automatic configure_shot(
        input [10:0] worm_x,
        input [10:0] worm_y,
        input [7:0]  angle,
        input [7:0]  power,
        input signed [7:0] current_wind
    );
        begin
            @(posedge clk);
            tb_worm_pos_x = worm_x;
            tb_worm_pos_y = worm_y;
            tb_aim_angle  = angle;
            tb_shot_power = power;
            tb_wind       = current_wind;
            $display("[TB TASK] Shot configured at (%0d, %0d) | Angle: %0d | Power: %0d | Wind: %0d", worm_x, worm_y, angle, power, current_wind);
        end
    endtask


    task automatic fire_bullet();
        int cycle_count;
        int flight_cycles;
        logic timeout_reached;
        begin
            cycle_count = 0;
            timeout_reached = 1'b0;

            // 1. Assert enable cleanly relative to clock edge
            @(posedge clk);
            @(negedge clk);
            tb_enable = 1'b1;
            $display("[TB TASK] Bullet enabled. Hardware Polar-to-Cartesian unit processing...");

            @(posedge clk);
            cycle_count++;

            // 2. Wait for mathematical hardware conversion to resolve
            while (!hw_conv_done && !timeout_reached) begin
                @(posedge clk);
                cycle_count++;
                if (cycle_count >= 50) begin 
                    timeout_reached = 1'b1;
                end
            end

            if (timeout_reached) begin
                $display("[TB TASK] ERROR: Polar-to-Cartesian conversion HUNG across clock boundaries!");
                $finish; 
            end

            $display("[TB TASK] Math Complete! HW Calculated Components: X=%0d, Y=%0d", hw_x_component, hw_y_component);
            $display("[TB TASK] Bullet flying... tracking coordinates.");
            
            // 3. Clocked monitoring loop replacing the raw asynchronous edge waiter
            flight_cycles = 0;
            timeout_reached = 1'b0;

            while (!mon_start_explosion && !timeout_reached) begin
                @(posedge clk);
                flight_cycles++;
                
                // Optional tracking display every 20 cycles
                if (flight_cycles % 20 == 0) begin
                    $display("[FLIGHT MONITOR] Frame cycle %0d: Current Pos=(%0d, %0d)", flight_cycles, mon_pos_x, mon_pos_y);
                end

                if (flight_cycles >= 2000) begin // Break if the bullet goes off-screen indefinitely
                    timeout_reached = 1'b1;
                end
            end

            if (timeout_reached) begin
                $display("[TB TASK] WARNING: Bullet flight tracking TIMED OUT without hitting anything!");
            end else begin
                $display("[TB TASK] Boom! Explosion triggered at Final Pos: (%0d, %0d) after %0d environment ticks", mon_pos_x, mon_pos_y, flight_cycles);
            end

            // 4. Clean shutdown sequence
            @(posedge clk);
            tb_enable = 1'b0;
            repeat(5) @(posedge clk);
        end
    endtask
    
    /**
     * Main test execution block
     */
    initial begin
        // 1. Setup initial states
        init_signals();

        // 2. Generate repeating sync/tick pulses dynamically in the background 
        // (Simulates physics engine/video updates every 10 clock cycles)
        fork
            forever begin
                tb_sync = 1'b0;
                repeat(9) @(posedge clk);
                tb_sync = 1'b1;
                @(posedge clk);
            end
        join_none

        // 3. Wait for system reset to complete
        @(negedge rst_n);
        @(posedge rst_n);
        repeat(5) @(posedge clk);

        // --- TEST SCENARIO 1: Standard Forward Shot ---
        $display("\n--- Starting Scenario 1 ---");
        configure_shot(.worm_x(11'd100), .worm_y(11'd200), .angle(8'd10), .power(8'd50), .current_wind(8'sd0));
        fire_bullet();


        // --- TEST SCENARIO 2: High Wind Backwards Shot ---
        $display("\n--- Starting Scenario 2 ---");
        configure_shot(.worm_x(11'd500), .worm_y(11'd200), .angle(8'd40), .power(8'd75), .current_wind(-8'sd20));
        fire_bullet();


        // Finish simulation safely
        repeat(10) @(posedge clk);
        $finish;
    end

endmodule