/*
 * Designed by MP
 * 
 * Description:
 * Testbench for explosion_consequences module.
 */

module explosion_consequences_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam TERRAIN_WIDTH = 1024;
    localparam TERRAIN_HEIGHT = 768;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic [$clog2(TERRAIN_WIDTH)-1:0] worm_pos_x;
    logic [$clog2(TERRAIN_HEIGHT)-1:0] worm_pos_y;

    logic [$clog2(TERRAIN_WIDTH)-1:0] explosion_pos_x;
    logic [$clog2(TERRAIN_HEIGHT)-1:0] explosion_pos_y;
    logic [10:0] explosion_r;

    logic start, done;

    logic signed [7:0] velocity_x;
    logic signed [7:0] velocity_y;
    logic [5:0] damage;
    

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

    /*
     * starting condition
     */

    initial begin
        @(negedge rst_n);
        @(posedge rst_n);

        worm_pos_x = '0;
        worm_pos_y = '0;
        explosion_pos_x = '0;
        explosion_pos_y = '0;
        explosion_r = '0;
        start = 1'b0;
    end
    


    /**
     * Dut placement
     */
    
    explosion_consequences #(
        .TERRAIN_WIDTH(TERRAIN_WIDTH),
        .TERRAIN_HEIGHT(TERRAIN_HEIGHT)
    ) dut (
        .clk,
        .rst_n,

        .worm_pos_x (worm_pos_x),
        .worm_pos_y (worm_pos_y),
        .explosion_pos_x (explosion_pos_x),
        .explosion_pos_y (explosion_pos_y),
        .explosion_r (explosion_r),
        .start (start),
        .velocity_x (velocity_x),
        .velocity_y (velocity_y),
        .damage (damage),
        .done (done)
    );


    /**
     * Tasks and functions
     */

    task automatic drive_explosion(
        input logic [$clog2(TERRAIN_WIDTH)-1:0]  w_x,
        input logic [$clog2(TERRAIN_HEIGHT)-1:0] w_y,
        input logic [$clog2(TERRAIN_WIDTH)-1:0]  e_x,
        input logic [$clog2(TERRAIN_HEIGHT)-1:0] e_y,
        input logic [10:0] rad,

        input logic signed [7:0] exp_vel_x,
        input logic signed [7:0] exp_vel_y,
        input logic [5:0] exp_damage
    );

        @(posedge clk);
        worm_pos_x = w_x;
        worm_pos_y = w_y;
        explosion_pos_x = e_x;
        explosion_pos_y = e_y;
        explosion_r = rad;
        start = 1'b1;

        @(posedge clk);
        start = 1'b0; 

        wait(done == 1'b1);
        
        assert(damage === exp_damage) begin
            $display("PASSED: damage: %d", damage);
        end else begin
            $error("FAILED: Damage expected: %d, Damage got: %d", exp_damage, damage);
        end
        
        assert(velocity_x === exp_vel_x)begin
            $display("PASSED: velocity_x: %d", velocity_x);
        end else begin
            $error("FAILED: velocity_x expected: %d, velocity_x got: %d", exp_vel_x, velocity_x);
        end

        assert(velocity_y === exp_vel_y)begin
            $display("PASSED: velocity_y: %d", velocity_y);
        end else begin
            $error("FAILED: velocity_y expected: %d, velocity_y got: %d", exp_vel_y, velocity_y);
        end

    endtask


    /**
     * Assertions
     */


    /**
     * Main test
     */

    initial begin

        @(negedge rst_n);
        @(posedge rst_n);

        repeat(2) @(posedge clk);

        /* inside of explosion */
        $display("Test inside of explosion");
        drive_explosion(.w_x(200), .w_y(150), .e_x(210), .e_y(145), .rad(30), .exp_vel_x(20), .exp_vel_y(25), .exp_damage(19));

        /* outside of explosion */
        $display("Test outside of explosion");
        drive_explosion(.w_x(500), .w_y(500), .e_x(100), .e_y(100), .rad(25), .exp_vel_x(0), .exp_vel_y(0), .exp_damage(0));

        $finish;
    end

endmodule
