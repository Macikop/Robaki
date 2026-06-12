/*
 * Designed by MP
 * * Description:
 * Testbench for cdc module.
 */

module cdc_tb;

    timeunit 1ns;
    timeprecision 1ps;


    /**
     * Local parameters
     */

    localparam CLK_A_PERIOD = 10;      // 100 MHz
    localparam CLK_B_PERIOD = 15.3846; // 65 MHz
    
    localparam RST_START_TIME  = 1.25 * CLK_A_PERIOD;
    localparam RST_ACTIVE_TIME = 2.00 * CLK_A_PERIOD;

    localparam STAGES = 2;
    localparam WIDTH  = 8;

    /**
     * Local variables and signals
     */

    logic clk_a;
    logic clk_b;
    logic rst_n;
    
    logic [WIDTH-1:0] data_in;
    logic             send_data;
    logic [WIDTH-1:0] data_out;

    logic [WIDTH-1:0] tb_data_sent;

    always_ff @(posedge clk_a or negedge rst_n) begin
        if (!rst_n) begin
            tb_data_sent <= '0;
        end else if (send_data) begin
            tb_data_sent <= data_in;
        end
    end

    /**
     * Clock generation
     */

    initial begin
        clk_a = 1'b0;
        forever #(CLK_A_PERIOD/2) clk_a = ~clk_a;
    end

    initial begin
        clk_b = 1'b0;
        forever #(CLK_B_PERIOD/2) clk_b = ~clk_b;
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
    
    cdc #(
        .STAGES (STAGES),
        .WIDTH  (WIDTH)
    ) dut (
        .clk_a     (clk_a),
        .clk_b     (clk_b),
        .rst_n     (rst_n),
        .data_in   (data_in),
        .send_data (send_data),
        .data_out  (data_out)
    );


    /**
     * Tasks and functions
     */

    task automatic init_inputs();
        data_in   = '0;
        send_data = 1'b0;
    endtask

    task automatic send_packet_domain_a(input logic [WIDTH-1:0] val);
        @(negedge clk_a);
        data_in   = val;
        send_data = 1'b1;
        @(negedge clk_a);
        send_data = 1'b0;
    endtask


    /**
     * Assertions
     */

    // 1. Reset Property (Immediate check upon reset)
    assert property (
        @(posedge clk_b)
        !rst_n |-> (data_out == '0)
    ) else begin
        $error("RESET: Data output clear failed on Domain B");
    end

    // 2. Data Stability Property
    assert property (
        @(posedge clk_b)
        disable iff (!rst_n)
        $changed(data_out) |-> (data_out == tb_data_sent)
    ) else begin
        $error("CDC CORRUPTION: Replicated data_out does not match held source value!");
    end


    /**
     * Main test
     */

    initial begin
        init_inputs();

        @(negedge rst_n);
        @(posedge rst_n);
        repeat (3) @(posedge clk_a);


        $display("Sending 8'hA5");
        send_packet_domain_a(8'hA5);
        
        repeat (6) @(posedge clk_b);

        // Send 0x3C
        $display("Sending 8'h3C");
        send_packet_domain_a(8'h3C);
        repeat (6) @(posedge clk_b);

        //Send 0xFF
        $display("Sending 8'hFF");
        send_packet_domain_a(8'hFF);
        repeat (6) @(posedge clk_b);

        repeat (5) @(posedge clk_b);

        $finish;
    end

endmodule