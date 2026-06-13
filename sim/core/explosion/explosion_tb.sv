/*
 * Designed by MP
 * Description:
 * Fully synchronous testbench for explosion module using tasks.
 * Fixed: Relocated explosion module to channel 0 to match WRITE_CHANNEL parameter.
 * Updated: Removed localized fork-join structure inside the stimulus task.
 */

module explosion_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD = 10;         // 100 MHz
    localparam CLK_VGA_PERIOD = 15.385; // 65 MHz
    localparam RST_START_TIME  = 1.25*CLK_VGA_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_VGA_PERIOD;

    localparam TERRAIN_WIDTH  = 1024;
    localparam TERRAIN_HEIGHT = 768;
    localparam ADDR_WIDTH     = $clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT);
    localparam WORD_WIDTH     = 1;
    localparam INPUTS_NUMBER  = 2;
    localparam WRITE_CHANNEL  = 0; // Only channel 0 can execute clear operations
    localparam RAM_DELAY      = 2;

    /**
     * Local variables and signals
     */

    logic clk;
    logic clk_vga;
    logic rst_n;

    /**
     * Reset generation
     */
    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end
    
    // VGA Timing Signals
    logic [10:0] vcount, hcount;
    logic vsync, hsync, vblnk, hblnk;
    
    // Video / Rendering Signals
    vga_if vga_bg();
    vga_if vga_out();
    logic [3:0]  r, g, b;
    logic        vs;
    
    // Terrain and RAM Architecture Connections
    logic [ADDR_WIDTH-1:0] address_core;
    logic [ADDR_WIDTH-1:0] address_terrain;
    logic                  clear_sig;
    logic                  clear;
    logic                  terrain_present;
    logic                  data_out_core;

    // Explosion Control Signals
    logic        exp_enable;
    logic        exp_sync;
    logic [10:0] exp_x;
    logic [10:0] exp_y;
    logic        exp_done;
    logic [7:0]  exp_radius;

    // Explosion Display Routing Signals
    logic [10:0] draw_exp_x, draw_exp_y, draw_exp_r;
    logic        draw_exp_en;
    logic [11:0] draw_exp_color;
    logic        ram_clear;

    // Route RGB outputs for the TIFF writer to read
    assign r  = vga_out.rgb[11:8];
    assign g  = vga_out.rgb[7:4];
    assign b  = vga_out.rgb[3:0];
    assign vs = vsync;

    /**
     * Interface Instance for Memory Bus
     */
    memory_if client_ifs[INPUTS_NUMBER](); 

    /**
     * Clock generation
     */
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        clk_vga = 1'b0;
        forever #(CLK_VGA_PERIOD/2) clk_vga = ~clk_vga;
    end

    /**
     * Dut placement
     */

    vga_timing u_vga_timing (
        .clk(clk_vga),
        .rst_n(rst_n),
        .vcount(vcount),
        .vsync(vsync),
        .vblnk(vblnk),
        .hcount(hcount),
        .hsync(hsync),
        .hblnk(hblnk)
    );

    draw_bg #(
        .COLOR(12'h0_a_a)
    ) u_draw_bg(
        .clk(clk_vga),
        .rst_n(rst_n),
        .vcount_in(vcount),
        .vsync_in(vsync),
        .vblnk_in(vblnk),
        .hcount_in(hcount),
        .hsync_in(hsync),
        .hblnk_in(hblnk),
        .vga_out(vga_bg)
    );

    terrain_ram #(
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map1.dat"),
        .WIDTH(TERRAIN_WIDTH),
        .HEIGHT(TERRAIN_HEIGHT)
    ) u_terrain_ram (
        .clk_vga(clk_vga),
        .clk_core(clk),
        .rst_n(rst_n),
        .address_core(address_core),
        .clear(clear_sig),
        .address_vga(address_terrain),
        .data_out_vga(terrain_present),
        .data_out_core(data_out_core)
    );

    ram_address_mux #(
        .ADDRESS_WIDTH(ADDR_WIDTH),
        .WORD_WIDTH(WORD_WIDTH),
        .INPUTS_NUMBER(INPUTS_NUMBER),
        .WRITE_CHANNEL(WRITE_CHANNEL),
        .RAM_DELAY(RAM_DELAY)
    ) u_ram_address_mux (
        .clk(clk),
        .rst_n(rst_n),
        .clients(client_ifs),
        .clear(clear),
        .ram_value(data_out_core),
        .ram_address(address_core),
        .ram_clear(clear_sig)
    );

    draw_terrain #(
        .TERRAIN_WIDTH(TERRAIN_WIDTH),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT),
        .X_OFFSET(0),
        .Y_OFFSET(0)
    ) u_draw_terrain (
        .clk(clk_vga),
        .rst_n(rst_n),
        .enable(1'b1),
        .color(12'h0_F_0),
        .data_in(terrain_present),
        .address(address_terrain),
        .vga_in(vga_bg),
        .vga_out(vga_out)
    );

    tiff_writer #(
        .XDIM(16'd1344),
        .YDIM(16'd806),
        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk_vga),
        .r({r, 4'b0000}), 
        .g({g, 4'b0000}), 
        .b({b, 4'b0000}), 
        .go(vs)
    );
    
    explosion #(
        .RADIUS(8'd45),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT),
        .TERRAIN_WIDTH(TERRAIN_WIDTH)
    ) dut (
        .clk                   (clk),
        .rst_n                 (rst_n),
        .enable                (exp_enable),
        .sync                  (exp_sync),
        .explosion_x           (exp_x),
        .explosion_y           (exp_y),
        .explosion_done        (exp_done),
        .explosion_radius      (exp_radius),
        .draw_explosion_x      (draw_exp_x),
        .draw_explosion_y      (draw_exp_y),
        .draw_explosion_r      (draw_exp_r),
        .draw_explosion_en     (draw_exp_en),
        .draw_explosion_color  (draw_exp_color),
        .ram_clear             (clear),
        .terrain_ram           (client_ifs[0]) 
    );

    initial forever begin
        repeat (100) @(posedge clk); 
        exp_sync <= 1'b1;
        @(posedge clk);
        exp_sync <= 1'b0;
    end


    /**
     * Tasks and functions
     */

    task automatic test_explosion_trigger(input [10:0] x, input [10:0] y);
        begin
            $display("Requesting explosion at coordinates: X=%0d, Y=%0d", x, y);
            
            @(posedge clk);
            exp_x      <= x;
            exp_y      <= y;
            exp_enable <= 1'b1; 
            
            @(posedge clk);
            exp_enable <= 1'b0;

            @(posedge exp_done);
            $display("Detected exp_done successfully for coordinates (%0d, %0d).", x, y);

            repeat (20) @(posedge clk);
        end
    endtask


    /**
     * Main test execution
     */

    initial begin
        client_ifs[1].request   = 1'b0;
        client_ifs[1].addresses = '0;

        exp_enable = 1'b0;
        exp_sync   = 1'b0;
        exp_x      = 11'd0;
        exp_y      = 11'd0;

        @(negedge rst_n);
        @(posedge rst_n);
        repeat (5) @(posedge clk);

        $display("Beginning of the test");

        test_explosion_trigger(11'd512, 11'd500);
        test_explosion_trigger(11'd200, 11'd400);

        @(posedge vsync);
        @(posedge vsync); 

        $display("Test complete. Finishing simulation...");
        $finish;
    end

endmodule
