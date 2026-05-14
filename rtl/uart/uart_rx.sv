/*
 * Designed by KS
 * How it works:
 * 
 *  
 */

module uart_rx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx_pin,
    output logic [7:0] rx_data,
    output logic       rx_done
);

    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [31:0] clk_count;
    logic [2:0]  bit_index;
    logic [7:0]  shift_reg;
  
    logic rx_sync;
    always_ff @(posedge clk) rx_sync <= rx_pin;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            rx_done <= 0;
        end else begin
            rx_done <= 0;
            case (state)
                IDLE: begin
                    if (rx_sync == 0) begin 
                        clk_count <= 0;
                        state     <= START;
                    end
                end

                START: begin
                    if (clk_count == (BIT_PERIOD / 2)) begin
                        if (rx_sync == 0) begin
                            clk_count <= 0;
                            state     <= DATA;
                            bit_index <= 0;
                        end else state <= IDLE;
                    end else clk_count <= clk_count + 1;
                end

                DATA: begin
                    if (clk_count < BIT_PERIOD - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        shift_reg[bit_index] <= rx_sync;
                        if (bit_index < 7) bit_index <= bit_index + 1;
                        else state <= STOP;
                    end
                end

                STOP: begin
                    if (clk_count < BIT_PERIOD - 1) clk_count <= clk_count + 1;
                    else begin
                        rx_data <= shift_reg;
                        rx_done <= 1;
                        state   <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
