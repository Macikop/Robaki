/*
 * Designed by MP
 * 
 * Description:
 * Testbench for terrain_destruction module.
 * Fixed interface structure compatibility.
 */

module terrain_destruction_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;

    /**
     * Local parameters
     */

    localparam CLK_PERIOD     = 10;         // 100 MHz
    localparam CLK_VGA_PERIOD = 15.385;     // 65 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam TERRAIN_WIDTH   = 1024; 
    localparam TERRAIN_HEIGHT  = 768;
    localparam RAM_DELAY       = 2;
    localparam ADDR_WIDTH      = $clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT);
    localparam WORD_WIDTH      = 1;
    localparam INPUTS_NUMBER   = 2;
    localparam WRITE_CHANNEL   = 1;

    /**
     * Local variables and signals
     */

    logic clk, clk_vga;
    logic rst_n;

    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;

    vga_if vga_out();
    vga_if vga_bg();

    wire terrain_present;
    wire [$clog2(TERRAIN_WIDTH * TERRAIN_HEIGHT)-1:0] address_terrain;

    wire vs, hs;
    wire [3:0] r, g, b;

    assign vs = vga_out.vsync;
    assign hs = vga_out.hsync;

    assign r = vga_out.rgb[11:8];
    assign g = vga_out.rgb[7:4];
    assign b = vga_out.rgb[3:0];

    memory_if client_ifs[0:INPUTS_NUMBER-1]();

    wire [ADDR_WIDTH-1:0]  address_core;
    wire                   clear_sig;
    wire [WORD_WIDTH-1:0]  data_out_core = 1'b0;

    logic                  dut_start;
    logic [10:0]           dut_pos_x;
    logic [10:0]           dut_pos_y;
    logic [7:0]            dut_radius;
    wire                   dut_done;

    wire clear;

    assign client_ifs[0].addresses = '0;
    assign client_ifs[0].request   = 1'b0;
    assign client_ifs[0].value     = 1'b0;

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
     * Reset generation
     */

    initial begin
        rst_n = 1'b1;
        #(RST_START_TIME) rst_n = 1'b0;
        #(RST_ACTIVE_TIME) rst_n = 1'b1;
    end

    /*
     * Supporting modules
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
        .COLOR(12'h0_0_f)
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
        .data_out_core()
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
        .r({r,r}),
        .g({g,g}),
        .b({b,b}),
        .go(vs)
    );

    /**
     * Dut placement
     */

    terrain_destruction #(
        .TERRAIN_WIDTH(TERRAIN_WIDTH),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT),
        .RAM_DELAY(RAM_DELAY)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(dut_start),
        .pos_x(dut_pos_x),
        .pos_y(dut_pos_y),
        .radius(dut_radius),
        .v_ram(client_ifs[1]),
        .ram_clear(clear),
        .done(dut_done)
    );

    /**
     * Tasks and functions
     */

    task automatic trigger_explosion(input [10:0] x, input [10:0] y, input [7:0] r);
        begin
            @(posedge clk);
            dut_pos_x = x;
            dut_pos_y = y;
            dut_radius = r;
            dut_start = 1'b1;
            
            @(posedge clk);
            dut_start = 1'b0;
            
            @(posedge dut_done);
            $display("Explosion at (%0d, %0d) with radius %0d completed.", x, y, r);
            repeat(5) @(posedge clk);
        end
    endtask

    /**
     * Main test
     */

    initial begin
        dut_start  = 1'b0;
        dut_pos_x  = '0;
        dut_pos_y  = '0;
        dut_radius = '0;

        @(posedge rst_n);
        repeat(10) @(posedge clk);

        trigger_explosion(11'd212, 11'd584, 8'd25);
        trigger_explosion(11'd530, 11'd390, 8'd45);

        $display("Check output frame");
        repeat(2) @(posedge vsync);

        $finish;
    end

endmodule
