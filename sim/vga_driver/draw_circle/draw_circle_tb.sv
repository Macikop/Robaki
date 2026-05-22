module draw_circle_tb;

    timeunit 1ns;
    timeprecision 1ps;

    import vga_pkg::*;


    /**
     *  Local parameters
     */

    localparam CLK_PERIOD = 15.385;     // 65 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam MODULE_DELAY = 2;


    /**
     * Local variables and signals
     */

    logic clk, rst_n;

    logic [10:0] vcount;
    logic        vsync;
    logic        vblnk;
    logic [10:0] hcount;
    logic        hsync;
    logic        hblnk;

    vga_if vga_out();
    vga_if vga_bg();

    wire vs, hs;
    wire [3:0] r, g, b;

    assign vs = vga_out.vsync;
    assign hs = vga_out.hsync;

    assign r = vga_out.rgb[11:8];
    assign g = vga_out.rgb[7:4];
    assign b = vga_out.rgb[3:0];


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
     * DUT placement
     */

    vga_timing u_vga_timing (
        .clk(clk),
        .rst_n(rst_n),

        .vcount(vcount),
        .vsync(vsync),
        .vblnk(vblnk),
        .hcount(hcount),
        .hsync(hsync),
        .hblnk(hblnk)
    );

    draw_bg u_draw_bg(
        .clk(clk),
        .rst_n(rst_n),

        .vcount_in(vcount),
        .vsync_in(vsync),
        .vblnk_in(vblnk),
        .hcount_in(hcount),
        .hsync_in(hsync),
        .hblnk_in(hblnk),

        .vga_out(vga_bg)
    );

    sprite_rom #(
        .SPRITE_PATH("../../rtl/vga_driver/sprite_bank/arrow.dat"),
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_sprite_rom (
        .clk,
        .rst_n

        .address(address_sprite),
        .rgb(rgb_sprite)

    );

    draw_sprite #(
        .WIDTH(SPRITE_WIDTH),
        .HEIGHT(SPRITE_HEIGHT)
    ) u_draw_sprite (
        .clk,
        .rst_n,
        
        .xpos(12'd100),
        .ypos(12'd100),
        .vga_in(vga_bg),

        .modifier(3'b000),

        .rgb_pixel(rgb_sprite),
        .pixel_addres(address_sprite),

        .vga_out(vga_out)
    );


    tiff_writer #(
        .XDIM(16'd1344),
        .YDIM(16'd806),
        .FILE_DIR("../../results")
    ) u_tiff_writer (
        .clk(clk),
        .r({r,r}),
        .g({g,g}),
        .b({b,b}),
        .go(vs)
    );

    /**
     * Assertions
     */

    /* hcount : max value */
    assert property (
        /* run assertion at each positive clock edge: */
        @(posedge clk)
        /* except during reset (optional): */
        disable iff (!rst_n || $realtime < RST_START_TIME)
        /* check whether this condition is true: */
        vga_out.hcount < HOR_TOTAL_TIME
    ) else begin
        /* if condition is not true, display error message */
        $error("hcount: max value exceeded");
    end

    /* hcount : zero after max value */
    assert property (
        @(posedge clk)
        vga_out.hcount == (HOR_TOTAL_TIME - 1) |=> vga_out.hcount == 0
    ) else begin
        $error("hcount: return to 0 after expected max value failed");
    end

    /* hcount : incrementation with every clock tick */
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        ($past(rst_n, MODULE_DELAY) && (vga_out.hcount < HOR_TOTAL_TIME - 1)) |=> (vga_out.hcount == $past(vga_out.hcount) + 1)
    ) else begin
        $error("hcount: increment at every clk failed");
    end

    /* vcount : max value */
    assert property (
        @(posedge clk)
        disable iff (!rst_n || $realtime < RST_START_TIME)
        vga_out.vcount < VER_TOTAL_TIME
    ) else begin
        $error("vcount: max value exceeded");
    end

    /* vcount : zero after max value */
    assert property (
        @(posedge clk)
        vga_out.vcount == (VER_TOTAL_TIME - 1) |=> ##(HOR_TOTAL_TIME - 1) vga_out.vcount == 0
    ) else begin
        $error("vcount: return to 0 after expected max value failed");
    end

    /* vcount : incrementation with every clock tick */
    assert property (
        @(posedge clk)
        (vga_out.hcount == HOR_TOTAL_TIME - 1) && vga_out.vcount < (VER_TOTAL_TIME - 1) |=> (vga_out.vcount == $past(vga_out.vcount) + 1)
    ) else begin
        $error("vcount: increment at hcount reset failed");
    end

    /* hblnk : set */
    assert property (
        @(posedge clk)
        vga_out.hcount >= HOR_BLANK_START && vga_out.hcount < HOR_BLANK_START + HOR_BLANK_TIME - 1 |-> vga_out.hblnk
    ) else begin
        $error("hblnk: set failed");
    end

    /* hblnk : clear */
    assert property (
        @(posedge clk)
        vga_out.hcount < HOR_BLANK_START |-> !vga_out.hblnk
    ) else begin
        $error("hblnk: clear failed");
    end

    /* vblnk : set */
    assert property (
        @(posedge clk)
        vga_out.vcount >= VER_BLANK_START && vga_out.vcount < VER_BLANK_START + VER_BLANK_TIME - 1 |-> vga_out.vblnk
    ) else begin
        $error("vblnk set failed");
    end

    /* vblnk : clear */
    assert property (
        @(posedge clk)
        vga_out.vcount < VER_BLANK_START |-> !vga_out.vblnk
    ) else begin
        $error("vblnk: clear failed");
    end

    /* hsync : set */
    assert property (
        @(posedge clk)
        vga_out.hcount >= HOR_SYNC_START && vga_out.hcount < HOR_SYNC_START + HOR_SYNC_TIME - 1 |-> vga_out.hsync
    ) else begin
        $error("hsync: set failed");
    end

    /* hsync : clear */
    assert property (
        @(posedge clk)
        (vga_out.hcount < HOR_SYNC_START) || (vga_out.hcount > (HOR_SYNC_START + HOR_SYNC_TIME - 1)) |-> !vga_out.hsync
    ) else begin
        $error("hsync: clear failed");
    end

    /* vsync : set */
    assert property (
        @(posedge clk)
        vga_out.vcount >= VER_SYNC_START && vga_out.vcount < VER_SYNC_START + VER_SYNC_TIME - 1 |-> vga_out.vsync
    ) else begin
        $error("vsync: set failed");
    end

    /* vsync : clear */
    assert property (
        @(posedge clk)
        vga_out.vcount < VER_SYNC_START || vga_out.vcount > VER_SYNC_START + VER_SYNC_TIME - 1 |-> !vga_out.vsync
    ) else begin
        $error("vsync: clear failed");
    end


    /**
     * Main test
     */

    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        wait (vga_out.vsync == 1'b0);
        @(negedge vga_out.vsync);
        @(negedge vga_out.vsync);

        $finish;
    end

endmodule