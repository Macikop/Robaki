/*
 * Designed by MP
 * * Description:
 * Testbench for physics_engine module with RAM MUX integration.
 */

module physics_engine_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */
    localparam int CLK_PERIOD = 10;     // 100 MHz
    localparam real RST_START_TIME = 1.25 * CLK_PERIOD;
    localparam real RST_ACTIVE_TIME = 2.00 * CLK_PERIOD;

    localparam int MAP_WIDTH = 1024;
    localparam int MAP_HEIGHT = 768;
    localparam int RAM_DELAY = 2;
    localparam int ADDR_WIDTH = $clog2(MAP_WIDTH * MAP_HEIGHT);

    // Mux-specific parameters
    localparam int MUX_INPUTS = 1; 

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    
    wire clk_vga; 
    wire clk_core;
    assign clk_vga  = clk; 
    assign clk_core = clk;

    wire [ADDR_WIDTH-1:0] address_vga = '0; 
    wire [ADDR_WIDTH-1:0] address_core;
    wire clear = 1'b0; // Defaulting clear to deasserted for standard reads
    wire data_out_vga;
    wire data_out_core;

    wire ram_request;
    wire granted; // Now driven by the Mux

    logic        sync;
    logic        start;
    logic signed [7:0] wind;
    logic signed [7:0] velocity_x_init;
    logic signed [7:0] velocity_y_init;
    
    logic [10:0] pos_x_init;
    logic [10:0] pos_y_init;

    wire [7:0]   cd_hit;
    wire         cd_done;
    wire         cd_start;
    wire         done;
    wire [10:0]  pos_x;
    wire [10:0]  pos_y;

    /**
     * Mux Interconnect Arrays
     */
    logic [ADDR_WIDTH-1:0] mux_addresses [0:MUX_INPUTS-1];
    logic                  mux_requests  [0:MUX_INPUTS-1];
    logic                  mux_values    [0:MUX_INPUTS-1];
    logic                  mux_granteds  [0:MUX_INPUTS-1];

    wire [ADDR_WIDTH-1:0]  mux_to_ram_address;
    wire                   mux_to_ram_clear;

    assign mux_addresses[0] = address_core;
    assign mux_requests[0]  = ram_request;
    assign data_out_core    = mux_values[0];
    assign granted          = mux_granteds[0];


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
     * Generates a sync signal whenever the machine needs to step or initialize.
     */

    initial begin
        sync = 1'b0;
        @(posedge rst_n);
        
        forever begin
            @(posedge clk);
            if ((dut.state == 3'b100) || (dut.state == 3'b000 && start)) begin
                sync = 1'b1;
                while ((dut.state == 3'b100) || (dut.state == 3'b000 && start)) begin
                    @(posedge clk);
                end
                sync = 1'b0;
            end
        end
    end

    /*
     * Supporting modules
     */

    terrain_ram #(
        .WIDTH(MAP_WIDTH),
        .HEIGHT(MAP_HEIGHT),
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map1.dat")
    ) u_terrain_ram (
        .clk_vga(clk_vga),
        .clk_core(clk_core),
        .rst_n(rst_n),
        .address_vga(address_vga),
        .address_core(mux_to_ram_address), // Routed from MUX
        .clear(mux_to_ram_clear),          // Routed from MUX
        .data_out_vga(data_out_vga),
        .data_out_core(raw_ram_data_out)
    );

    collision_detector #(
        .WIDTH(16),            
        .HEIGHT(16),            
        .RAM_DELAY(RAM_DELAY),
        .TERRAIN_WIDTH(MAP_WIDTH),
        .TERRAIN_HEIGHT(MAP_HEIGHT)
    ) u_collision_detector (
        .clk(clk),
        .rst_n(rst_n),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .start_check(cd_start),
        .is_occupied(data_out_core),
        .granted(granted),
        .terrain_address(address_core),
        .ram_request(ram_request),
        .collisions(cd_hit),
        .done(cd_done)
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
        .addresses(mux_addresses),
        .request(mux_requests),
        .clear('0),
        .ram_value(raw_ram_data_out),
        .value(mux_values),
        .granted(mux_granteds),
        .ram_address(mux_to_ram_address),
        .ram_clear(mux_to_ram_clear)
    );

    /**
     * Dut placement
     */

    physics_engine #(
        .GRAVITY(50),
        .MAP_WIDTH(MAP_WIDTH),
        .MAP_HEIGHT(MAP_HEIGHT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .sync(sync),
        .start(start),
        .wind(wind),
        .velocity_x_init(velocity_x_init),
        .velocity_y_init(velocity_y_init),
        .pos_x_init(pos_x_init), 
        .pos_y_init(pos_y_init), 
        .cd_hit(cd_hit),
        .cd_done(cd_done),
        .cd_start(cd_start),
        .done(done),
        .pos_x(pos_x),
        .pos_y(pos_y)
    );


    /**
     * Tasks and functions
     */

    task run_physics_trajectory(
        input [10:0] init_x,
        input [10:0] init_y,
        input signed [7:0] w,
        input signed [7:0] vx,
        input signed [7:0] vy
    );

        pos_x_init = init_x;
        pos_y_init = init_y;
        wind = w;
        velocity_x_init = vx;
        velocity_y_init = vy;

        while (dut.state != 3'b000) begin
            @(posedge clk);
        end
        
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        
        @(posedge done);

        $display("Trajectory completed. Spawned at (%0d, %0d) -> Impacted at (%0d, %0d)", init_x, init_y, pos_x, pos_y);
        repeat (5) @(posedge clk);
    endtask

    /**
     * Main test sequences
     */

    initial begin
        start = 1'b0;
        wind = 8'sd0;
        velocity_x_init = 8'sd0;
        velocity_y_init = 8'sd0;
        pos_x_init = 11'd0;
        pos_y_init = 11'd0;

        @(posedge rst_n);
        repeat (5) @(posedge clk);

        $display("Dropping projectile from screen position (10, 10, without wind).");
        run_physics_trajectory(11'd10, 11'd10, 8'sd0, 8'sd0, 8'sd5);

        $display("Dropping projectile from screen position (10, 10, with wind).");
        run_physics_trajectory(11'd10, 11'd10, 8'sd10, 8'sd0, 8'sd5);

        $display("Launching weapon from (50, 70) with wind.");
        run_physics_trajectory(11'd50, 11'd70, 8'sd4, 8'sd35, -8'sd40);

        $display("Launching flat high-speed shot from center map.");
        run_physics_trajectory(11'd512, 11'd100, -8'sd2, 8'sd75, 8'sd2);

        $finish;
    end

endmodule
