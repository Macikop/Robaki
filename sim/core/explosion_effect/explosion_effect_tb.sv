/*
 * Designed by MP
 * 
 * Description:
 * Testbench for explosion_effect module.
 */

module explosion_effect_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;


    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    
    logic sync;
    logic explosion_enable;
    logic [10:0] explosion_x;
    logic [10:0] explosion_y;
    logic [7:0]  expolsion_radius;

    logic draw_enable;
    logic [10:0] pos_x;
    logic [10:0] pos_y;
    logic [10:0] radius;
    logic [11:0] color;
    logic done;


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
     * Dut placement
     */
    
    explosion_effect dut (
        .clk              (clk),
        .rst_n            (rst_n),
        .sync             (sync),
        .explosion_enable (explosion_enable),
        .explosion_x      (explosion_x),
        .explosion_y      (explosion_y),
        .expolsion_radius (expolsion_radius),
        .draw_enable      (draw_enable),
        .pos_x            (pos_x),
        .pos_y            (pos_y),
        .radius           (radius),
        .color            (color),
        .done             (done)
    );


    /**
     * Tasks and functions
     */

    task automatic init_inputs();
        sync             = 1'b0;
        explosion_enable = 1'b0;
        explosion_x      = '0;
        explosion_y      = '0;
        expolsion_radius = '0;
    endtask

    task automatic pulse_sync();
        @(negedge clk);
        sync = 1'b1;
        @(negedge clk);
        sync = 1'b0;
    endtask

    task automatic trigger_explosion(
        input logic [10:0] x, 
        input logic [10:0] y, 
        input logic [7:0]  r
    );
        @(negedge clk);
        explosion_enable = 1'b1;
        explosion_x      = x;
        explosion_y      = y;
        expolsion_radius = r;
        
        sync = 1'b1;
        @(negedge clk);
        sync = 1'b0;
    endtask


    /**
     * Assertions
     */

    /**
     * Assertions
     */

    // 1. Reset Assertion
    assert property (
        @(posedge clk)
        !rst_n |-> (draw_enable == 1'b0 && done == 1'b0 && color == 12'h0)
    ) else begin
        $error("RESET: initialization or clear failed");
    end

    // 2. Yellow Color & Draw Verification
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (draw_enable && (color == 12'hF_F_0)) |-> (pos_x == explosion_x && pos_y == explosion_y && radius == expolsion_radius)
    ) else begin
        $error("YELLOW STATE: Target positioning data or color value mismatched");
    end

    // 3. Orange State Vector Verification
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (draw_enable && color == 12'hF_F_0 && sync) |=> ##1 (color == 12'hF_A_0 && draw_enable == 1'b1)
    ) else begin
        $error("ORANGE STATE: Transition from Yellow following sync pulse failed");
    end

    // 4. Red State & Done Verification
    assert property (
        @(posedge clk)
        disable iff (!rst_n)
        (draw_enable && color == 12'hF_A_0 && sync) |=> ##1 (color == 12'hF_0_0 && draw_enable == 1'b1 && done == 1'b1)
    ) else begin
        $error("RED STATE: Termination parameters or final stage flag failed");
    end


    /**
     * Main test
     */

    initial begin
        init_inputs();

        @(negedge rst_n);
        @(posedge rst_n);
        repeat (2) @(posedge clk);


        $display("Standard Sequence (Yellow -> Orange -> Red)");
        trigger_explosion(.x(11'd256), .y(11'd128), .r(8'd45));

        repeat (3) @(posedge clk);

        pulse_sync();
        repeat (3) @(posedge clk);

        pulse_sync();
        repeat (3) @(posedge clk);

        pulse_sync();
        @(posedge clk);
        
        @(negedge clk);
        explosion_enable = 1'b0;
        repeat (5) @(posedge clk);

        $finish;
    end

endmodule