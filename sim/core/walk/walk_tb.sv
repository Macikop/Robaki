/*
 * Designed by MP / Updated for dynamic hardware testing with RAM handshakes
 * Description:
 * Testbench for walk module with decoupled sub-step tracking.
 */

module walk_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD       = 10;     // 100 MHz
    localparam RST_START_TIME   = 1.25 * CLK_PERIOD;
    localparam RST_ACTIVE_TIME  = 2.00 * CLK_PERIOD;

    localparam MAP_WIDTH        = 1024;
    localparam MAP_HEIGHT       = 768;
    localparam SPEED            = 10;
    localparam GRAVITY          = 10;      // Matched to module parameter
    localparam RAM_DELAY        = 2;
    localparam ADDR_WIDTH       = $clog2(MAP_HEIGHT * MAP_WIDTH);     
    localparam MUX_INPUTS       = 3;      

    /**
     * Local variables and signals
     */
    logic clk;
    logic rst_n;

    // Walk DUT inputs/outputs
    logic        enable;
    logic        sync;
    logic        left;
    logic        right;
    logic [10:0] pos_x_init;
    logic [10:0] pos_y_init;
    logic [20:0]  collisions;
    logic        detector_done;
    logic        start_check;
    logic [10:0] detector_pos_x;
    logic [10:0] detector_pos_y;
    logic [10:0] pos_x;
    logic [10:0] pos_y;
    logic done;

    // Infrastructure interconnects
    logic [ADDR_WIDTH-1:0] mux_to_ram_address;
    logic                  mux_to_ram_clear;
    logic                  raw_ram_data_out;
    
    // Interface instantiations
    memory_if mux_client_ifs [0:MUX_INPUTS-1](); 
    logic [10:0]           cd_pos_x, cd_pos_y;
    logic                  cd_start, cd_done;
    logic [20:0]            cd_hit;

    logic [10:0] init_x = 11'd200;
    logic [10:0] init_y = 11'd100;

    // Unused mux channel grounding
    assign mux_client_ifs[0].addresses = '0;
    assign mux_client_ifs[0].request   = 1'b0;
    assign mux_client_ifs[2].addresses = '0;
    assign mux_client_ifs[2].request   = 1'b0;

    // Connect environment sub-modules to DUT hooks
    assign cd_pos_x      = detector_pos_x;
    assign cd_pos_y      = detector_pos_y;
    assign cd_start      = start_check;
    assign detector_done = cd_done;
    assign collisions    = cd_hit;

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
        #(RST_START_TIME)  rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /**
     * Frame Sync Generator (Every 1000 clock cycles)
     */
    initial begin
        forever begin
            sync = 1'b0;
            repeat(9999) @(posedge clk);
            sync = 1'b1;
            @(posedge clk);
        end
    end

    /**
     * Dynamic Tracking and RAM Grant Emulation
     * Refactored: We only catch and apply 'pos_x_init' updates on sync pulses!
     */
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pos_x_init <= init_x;
            pos_y_init <= init_y;
        end else begin
            if (done) begin
                pos_x_init <= pos_x;
                pos_y_init <= pos_y;
            end
        end
    end

    /**
     * Submodules
     */
    terrain_ram #(
        .WIDTH(MAP_WIDTH),
        .HEIGHT(MAP_HEIGHT),
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

    walking_collision #(          
        .RAM_DELAY(RAM_DELAY),
        .TERRAIN_WIDTH(MAP_WIDTH),
        .TERRAIN_HEIGHT(MAP_HEIGHT)
    ) u_walking_collision (
        .clk(clk),
        .rst_n(rst_n),
        .pos_x(cd_pos_x),
        .pos_y(cd_pos_y),
        .start(cd_start),
        .ram_client(mux_client_ifs[1].out), 
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
        .clients(mux_client_ifs),
        .clear('0),
        .ram_value(raw_ram_data_out),
        .ram_address(mux_to_ram_address),
        .ram_clear(mux_to_ram_clear)
    );

    /**
     * DUT Placement
     */
    walk #(
        .SPEED(SPEED),
        .GRAVITY(GRAVITY),
        .TERRAIN_WIDTH(MAP_WIDTH),
        .TERRAIN_HEIGHT(MAP_HEIGHT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .sync(sync),
        .left(left),
        .right(right),
        .pos_x_init(pos_x_init),
        .pos_y_init(pos_y_init),
        .collisions(collisions),
        .detector_done(detector_done),
        .start_check(start_check),
        .detector_pos_x(detector_pos_x),
        .detector_pos_y(detector_pos_y),
        .pos_x(pos_x),
        .pos_y(pos_y),
        .done(done)
    );

    /**
     * Main test execution sequence
     */
    initial begin
        // Initialize Control Flags
        enable = 1'b0;
        left   = 1'b0;
        right  = 1'b0;
        
        // Wait for Reset Sequence to Finish
        @(posedge rst_n);
        repeat (10) @(posedge clk);
        
        $display("[TB] --- Starting Walk Module Simulation ---");
        enable = 1'b1;

        // Test Phase 1: Pure Falling (No horizontal inputs pressed)
        $display("[TB] Testing Gravity Phase (Falling to ground)...");
        repeat (15) @(posedge sync);

        // Test Phase 2: Walk Right (Should handle level terrain & ascend slopes)
        $display("[TB] Testing Horizontal Walk Right & Slope Climbing...");
        right = 1'b1;
        repeat (40) @(posedge sync);
        right = 1'b0;

        // Test Phase 3: Walk Left
        $display("[TB] Testing Horizontal Walk Left...");
        left = 1'b1;
        repeat (40) @(posedge sync);
        left = 1'b0;

        // Wrap up execution
        repeat (100) @(posedge clk);
        $display(" --- All Test Tasks Finished ---");
        $finish;
    end

endmodule