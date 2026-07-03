/*
 * Designed by MP
 * * Description:
 * Testbench for polar_to_cartesian module.
 */

module polar_to_cartesian_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_PERIOD = 10;     // 100 MHz
    localparam RST_START_TIME  = 1.25*CLK_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00*CLK_PERIOD;

    localparam PI = 3.141592653589793;

    /**
     * Local variables and signals
     */

    logic clk;
    logic rst_n;

    logic [7:0] sin_address;
    logic [7:0] sin_value;

    logic start, done;
    logic [7:0] phi;
    logic [7:0] lenght;

    logic signed [7:0] x_component, y_component;
    

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
     * Sine Lut
     */

    sine_lut u_sine_lut(
        .clk,
        .rst_n,

        .addr(sin_address),
        .value(sin_value)
    );


    /**
     * Dut placement
     */
    
    polar_to_cartesian dut (
        .clk,
        .rst_n,

        .start(start),
        .phi(phi),
        .length(lenght),
        .lut_value(sin_value),
        .lut_address(sin_address),
        .x_component(x_component),
        .y_component(y_component),
        .done(done)
    );


    /**
     * Tasks and functions
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

    task automatic test_polar_conversion(input logic [7:0] t_phi, input logic [7:0] t_length);
        logic signed [8:0] expected_x;
        logic signed [8:0] expected_y;
        
        expected_x = get_expected_x(t_phi, t_length);
        expected_y = get_expected_y(t_phi, t_length);

        start  <= 1'b0;
        phi    <= t_phi;
        lenght <= t_length;
        @(posedge clk);
        
        start  <= 1'b1;
        @(posedge clk);
        start  <= 1'b0;
        
        while (!done) begin
            @(posedge clk);
        end
        
        assert ((x_component >= (expected_x - 1)) && (x_component <= (expected_x + 1)) && (y_component >= expected_y - 1) && (y_component <= expected_y + 1)) begin
            $display("PASSED within +/-1 Phi=%0d, lenght = %0d, Expected: X=%0d Y=%0d, got X=%0d Y=%0d", t_phi, t_length, expected_x, expected_y, x_component, y_component);
        end else begin
            $error("FAILED  DUT: X=%0d Y=%0d | Expected: X=%0d Y=%0d", x_component, y_component, expected_x, expected_y);
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

        for (int i = 0; i < 256; i = i + 1) begin
            test_polar_conversion(i, 100);
        end
        
        $finish;
    end

endmodule
