/*
 * Designed by KS
 * How it works:
 * 
 */

`timescale 1ns / 1ps

module top_UART #(
    parameter CLK_FREQ   = 100_000_000, // 100 MHz clock
    parameter BAUD_RATE  = 115200,      // baud rate
    parameter FIFO_DEPTH = 16           // tx, rx buffers
)(
    input  logic       clk,         // system clock (100mhz)
    input  logic       rst_n,  
    
    input  logic       uart_rx,     // RX physical pin
    output logic       uart_tx,     // TX physical pin
    
    input  logic       wr_en,       // Push byte into TX FIFO
    input  logic [7:0] wr_data,     // Byte to be transmitted
    input  logic       rd_en,       // Pop byte from RX FIFO
    output logic [7:0] rd_data,     // Received byte ready for system
    
    output logic       tx_full,     // Cannot write more data to transmit
    output logic       rx_empty     // No data available to read yet
);

    logic baud_tick;
    
    logic       tx_fifo_empty;
    logic       tx_fifo_rd_en;
    logic [7:0] tx_fifo_out;
    logic       tx_done;
    
    logic       rx_ready;
    logic [7:0] rx_shift_out;
    logic       rx_fifo_full;

    baud_rate_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) u_baud_rate_generator (
        .clk100MHz(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    //TX
    uart_FIFO #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_uart_FIFO (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .rd_en(tx_fifo_rd_en),
        .rd_data(tx_fifo_out),
        .full(tx_full),
        .empty(tx_fifo_empty)
    );

    tx_shift_register u_tx_shift_register (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_fifo_rd_en),
        .baud_tick(baud_tick),
        .tx_data(tx_fifo_out),
        .tx_serial(uart_tx),
        .tx_done(tx_done)
    );

    rx_shift_register u_rx_shift_register (
        .clk(clk),
        .rst_n(rst_n),
        .rx_serial(uart_rx),
        .baud_tick(baud_tick),
        .rx_ready(rx_ready),
        .rx_data(rx_shift_out)
    );


    //RX
    uart_FIFO #(
        .DATA_WIDTH(8),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) rx_fifo_inst (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(rx_ready),      
        .wr_data(rx_shift_out),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .full(rx_fifo_full),
        .empty(rx_empty)
    );


    typedef enum logic {TX_IDLE, TX_SENDING} tx_ctrl_state_t;
    tx_ctrl_state_t tx_state_reg, tx_state_next;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_state_reg <= TX_IDLE;
        end else begin
            tx_state_reg <= tx_state_next;
        end
    end

    always_comb begin
        tx_state_next = tx_state_reg;
        tx_fifo_rd_en = 1'b0;

        case (tx_state_reg)
            TX_IDLE: begin
                if (!tx_fifo_empty) begin
                    tx_fifo_rd_en = 1'b1; 
                    tx_state_next = TX_SENDING;
                end
            end
            
            TX_SENDING: begin
                if (tx_done) begin
                    tx_state_next = TX_IDLE;
                end
            end
        endcase
    end

endmodule