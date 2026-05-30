/*
 * Designed by MP
 *
 * Description:
 * Testbench for terrain_ram module.
 */

module terrain_ram_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam int WIDTH  = 4;
    localparam int HEIGHT = 4;

    localparam int SIZE   = WIDTH * HEIGHT;
    localparam int ADDR_W = $clog2(SIZE);

    localparam CLK_VGA_PERIOD  = 15.385;   // 65 MHz
    localparam CLK_CORE_PERIOD = 10;   // 100 MHz

    localparam RST_START_TIME  = 1.25 * CLK_CORE_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_CORE_PERIOD;


    /**
     * Local variables and signals
     */

    logic clk_vga;
    logic clk_core;
    logic rst_n;

    logic [ADDR_W-1:0] address_vga;
    logic [ADDR_W-1:0] address_core;

    logic clear;

    logic data_out_vga;
    logic data_out_core;


    /**
     * Clock generation
     */

    initial begin
        clk_vga = 1'b0;
        forever #(CLK_VGA_PERIOD/2) clk_vga = ~clk_vga;
    end

    initial begin
        clk_core = 1'b0;
        forever #(CLK_CORE_PERIOD/2) clk_core = ~clk_core;
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
     * DUT placement
     */

    terrain_ram #(
        .WIDTH(WIDTH),
        .HEIGHT(HEIGHT),
        .TERRAIN_FILE_PATH("../../rtl/vga_driver/maps/map_test.dat")
    ) dut (
        .clk_vga(clk_vga),
        .clk_core(clk_core),

        .rst_n(rst_n),

        .address_vga(address_vga),
        .address_core(address_core),

        .clear(clear),

        .data_out_vga(data_out_vga),
        .data_out_core(data_out_core)
    );


    /**
     * Tasks and functions
     */

    task automatic check_vga_read(
        input logic [ADDR_W-1:0] addr,
        input logic expected
    );
        begin
            address_vga = addr;

            @(posedge clk_vga);

            assert(data_out_vga == expected)
            else begin
                $error("VGA READ ERROR: addr=%0d expected=%0b got=%0b", addr, expected, data_out_vga);
            end
        end
    endtask


    task automatic check_core_read(
        input logic [ADDR_W-1:0] addr,
        input logic expected
    );
        begin
            @(negedge clk_core);
            address_core = addr;

            @(posedge clk_core);
            @(negedge clk_core);

            assert(data_out_core == expected)
            else begin
                $error("CORE READ ERROR: addr=%0d expected=%0b got=%0b",addr, expected, data_out_core);
            end
        end
    endtask


    task automatic clear_address(
        input logic [ADDR_W-1:0] addr
    );
    begin
        @(negedge clk_core);
        address_core = addr;
        clear = 1'b1;

        @(posedge clk_core);

        @(negedge clk_core);
        clear = 1'b0;

        @(posedge clk_core);
    end
    endtask


    /**
     * Main test
     */

    initial begin

        /**
         * Initial values
         */

        address_vga  = '0;
        address_core = '0;
        clear        = 1'b0;


        /**
         * Wait for reset
         */

        @(negedge rst_n);
        @(posedge rst_n);


        /**
         * Check reset values
         */

        @(posedge clk_vga);

        assert(data_out_vga !== 1'bx)
        else $error("Reset failed for VGA output");

        @(posedge clk_core);

        assert(data_out_core !== 1'bx)
        else $error("Reset failed for CORE output");


        check_vga_read(0, 1'b0);
        check_vga_read(1, 1'b1);

        check_core_read(2, 1'b1);
        check_core_read(3, 1'b0);


        /**
         * Test clear operation
         */

        clear_address(2);

        check_core_read(2, 1'b0);


        /**
         * End simulation
         */

        $display("TEST FINISHED");

        $finish;
    end

endmodule
