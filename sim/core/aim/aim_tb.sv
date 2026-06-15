/*
 * Designed by MP
 * 
 * Description:
 * Testbench for aim module
 */

module aim_tb;

    timeunit 1ns;
    timeprecision 1ps;

    /**
     * Local parameters
     */
    localparam CLK_PERIOD = 10; // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam [7:0]  TB_AIM_DISTANCE = 8'd50;
    localparam [10:0] TB_X_OFFSET     = 11'd16;
    localparam [10:0] TB_Y_OFFSET     = 11'd16;
    localparam PI = 3.141592653589793;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;
    
    logic        sync;
    logic        up;
    logic        down;
    logic        [10:0] x_pos;
    logic        [10:0] y_pos;
    logic        orientation;
    logic        calc_done;
    logic        start_calc;
    logic        [7:0]  aim_angle;
    logic        [7:0]  length;
    logic        [10:0] x_out;
    logic        [10:0] y_out;
    logic        enable;

    logic [7:0]  lut_addr;
    logic [7:0]  lut_value; 
    logic signed [7:0] x_comp, y_comp; 

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
    sine_lut u_sine_lut (
        .clk   (clk),
        .rst_n (rst_n),
        .addr  (lut_addr),
        .value (lut_value)
    );

    polar_to_cartesian u_polar_to_cartesian (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start_calc), 
        .phi         (aim_angle),  
        .length      (length),     
        .lut_value   (lut_value),
        .lut_address (lut_addr),
        .x_component (x_comp),
        .y_component (y_comp),
        .done        (calc_done)   
    );
    
    aim #(
        .AIM_DISTACNE (TB_AIM_DISTANCE),
        .X_OFFSET     (TB_X_OFFSET),
        .Y_OFFSET     (TB_Y_OFFSET)
    ) dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .sync         (sync),
        .up           (up),
        .down         (down),
        .x_aim        (x_comp), 
        .y_aim        (y_comp), 
        .x_pos        (x_pos),
        .y_pos        (y_pos),
        .orientation  (orientation),
        .calc_done    (calc_done),
        .start_calc   (start_calc),
        .aim_angle    (aim_angle),
        .length       (length),
        .x_out        (x_out),
        .y_out        (y_out),
        .enable       (enable)
    );

    /**
     * Helper Tasks
     */

    function automatic logic signed [7:0] get_expected_x(
        input logic [7:0] f_phi,
        input logic [7:0] f_length
    );
        real angle_rad;
        real ideal_cos;

        logic signed [8:0] scaled_cos;
        logic signed [15:0] product;

        angle_rad = (2.0 * PI * real'(f_phi)) / 256.0;
        ideal_cos = $cos(angle_rad);

        scaled_cos = $rtoi(ideal_cos * 128.0);

        product = $signed({1'b0,f_length}) * scaled_cos;

        return product >>> 7;
    endfunction
    
    function automatic logic signed [7:0] get_expected_y(
        input logic [7:0] f_phi,
        input logic [7:0] f_length
    );
        real angle_rad;
        real ideal_sin;

        logic signed [8:0] scaled_sin;
        logic signed [15:0] product;

        angle_rad = (2.0 * PI * real'(f_phi)) / 256.0;
        ideal_sin = $sin(angle_rad);

        scaled_sin = $rtoi(ideal_sin * 128.0);

        product = $signed({1'b0,f_length}) * scaled_sin;

        return product >>> 7;
    endfunction

    
    task init_inputs();
        sync        = 1'b0;
        up          = 1'b0;
        down        = 1'b0;
        x_pos       = 11'd0;
        y_pos       = 11'd0;
        orientation = 1'b1; 
        enable      = 1'b0;
        x_comp      = 8'sd0;
        y_comp      = 8'sd0;
        calc_done   = 1'b0;
    endtask

    task pulse_controls(input logic test_up, input logic test_down, input logic test_sync);
        @(posedge clk);
        sync = test_sync;
        up   = test_up;
        down = test_down;
        @(posedge clk);
        sync = 1'b0;
        up   = 1'b0;
        down = 1'b0;
    endtask

    task run_test_disabled();
        $display("Running Task 1: Disabled Sync");
        enable = 1'b0;
        pulse_controls(.test_up(1'b1), .test_down(1'b0), .test_sync(1'b1));
        
        repeat(3) @(posedge clk);
        
        assert(start_calc === 1'b0) begin
            $display("PASSED Task 1: when enable was low, start_calc stayed low");
        end else begin
            $error("FAILED Task 1: start_calc fired while enable was low!");
        end
            
    endtask

    task run_test_increment_calculation();
        logic [10:0] expected_x, expected_y;
        $display("Running Task 2: Up Increment Calculation");
        enable = 1'b1;
        x_pos  = 11'd200;
        y_pos  = 11'd150;
        orientation = 1'b1; 
        
        pulse_controls(.test_up(1'b1), .test_down(1'b0), .test_sync(1'b1));
        wait(calc_done == 1'b1);
        repeat(2) @(posedge clk);
        pulse_controls(.test_up(1'b1), .test_down(1'b0), .test_sync(1'b1));
        wait(calc_done == 1'b1);
        repeat(2) @(posedge clk);
        pulse_controls(.test_up(1'b1), .test_down(1'b0), .test_sync(1'b1));
        wait(calc_done == 1'b1);
        repeat(2) @(posedge clk);
        pulse_controls(.test_up(1'b1), .test_down(1'b0), .test_sync(1'b1));

        wait(calc_done == 1'b1);
        repeat(2) @(posedge clk);
        @(negedge clk);

        expected_x = x_pos + get_expected_x(aim_angle, length) - TB_X_OFFSET;
        expected_y = y_pos + get_expected_y(aim_angle, length) - TB_Y_OFFSET;

        assert((x_out >= (expected_x - 1)) && (x_out <= (expected_x + 1))) begin 
            $display("PASSED Task 2: Got: %d", x_out);
        end else begin
            $error("FAILED Task 2: x_out mismatch! Got %d, Expected %d", x_out, expected_x);
        end

        assert((y_out >= (expected_y - 1)) && (y_out <= (expected_y + 1))) begin
            $display("PASSED Task 2: Got: %d", y_out);
        end else begin
            $error("FAILED Task 2: y_out mismatch! Got %d, Expected %d", y_out, expected_y);
        end

        repeat(2) @(posedge clk);

    endtask

    task run_test_snap_mechanic();
        logic [10:0] expected_x, expected_y;
        $display("Running Task 3: Orientation Snap");
        enable = 1'b1;
        x_pos  = 11'd100;
        y_pos  = 11'd100;
        
        @(posedge clk);
        
        sync        = 1'b1;
        orientation = 1'b0;
        up          = 1'b0;
        down        = 1'b0;
        @(posedge clk);
        sync        = 1'b0;
        
        wait(start_calc == 1'b1);

        wait(calc_done == 1'b1);
        
        assert(aim_angle == 8'd128) 
            else $error("FAILED Task 3: aim_angle did not snap to 128! Got %d", aim_angle);

        wait(calc_done == 1'b1);
        repeat(2) @(posedge clk);
        @(negedge clk)
        
        expected_x = x_pos + get_expected_x(aim_angle, length) - TB_X_OFFSET;
        expected_y = y_pos + get_expected_y(aim_angle, length) - TB_Y_OFFSET;

        assert((x_out >= (expected_x - 1)) && (x_out <= (expected_x + 1))) begin 
            $display("PASSED Task 3: Got: %d", x_out);
        end else begin
            $error("FAILED Task 3: x_out mismatch! Got %d, Expected %d", x_out, expected_x);
        end

        assert((y_out >= (expected_y - 1)) && (y_out <= (expected_y + 1))) begin
            $display("PASSED Task 3: Got: %d", y_out);
        end else begin
            $error("FAILED Task 3: y_out mismatch! Got %d, Expected %d", y_out, expected_y);
        end

        repeat(2) @(posedge clk);

    endtask

    /**
     * Main test
     */

    initial begin
        init_inputs();
        wait(rst_n == 1'b1);
        repeat(2) @(posedge clk);

        run_test_disabled();
        run_test_increment_calculation();
        run_test_snap_mechanic();

        $display("All tests finished");
        $finish;
    end

endmodule
