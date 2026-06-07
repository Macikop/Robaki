/*
 * Designed by KS
 * How it works:
 *
 *  Write Pointer (w_ptr): Points to the next empty slot where data will be written
 *
 *  Read Pointer (r_ptr): Points to the oldest valid data byte that is ready to be read
 *
 *  FIFO Full: The write pointer has caught up to the read pointer from behind
 *
 *  FIFO Empty: The read pointer has caught up to the write pointer, meaning all data has been read
 */

`timescale 1ns / 1ps

module uart_fifo #(
    parameter DATA_WIDTH = 8,                   // 8 bits for uart
    parameter FIFO_DEPTH = 16                   // power of 2 
)(
    input  logic                    clk,       // 100 MHz
    input  logic                    rst_n,    
    
    input  logic                    wr_en,     // write enable
    input  logic [DATA_WIDTH-1:0]   wr_data,   // data to write
    
    input  logic                    rd_en,     // read enable
    output logic [DATA_WIDTH-1:0]   rd_data,   // data to read
    
    output logic                    full,      // FIFO full
    output logic                    empty      // FIFO empty
);

    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic [DATA_WIDTH-1:0] memory [FIFO_DEPTH-1:0];

    logic [ADDR_WIDTH:0] w_ptr_reg, w_ptr_next;
    logic [ADDR_WIDTH:0] r_ptr_reg, r_ptr_next;

    always_ff @(posedge clk) begin
        if (wr_en && !full) begin
            memory[w_ptr_reg[ADDR_WIDTH-1:0]] <= wr_data;
        end
    end

    assign rd_data = memory[r_ptr_reg[ADDR_WIDTH-1:0]];


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_ptr_reg <= '0;
            r_ptr_reg <= '0;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
        end
    end


    always_comb begin
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;

        if (wr_en && !full) begin
            w_ptr_next = w_ptr_reg + 1'b1;
        end
        
        if (rd_en && !empty) begin
            r_ptr_next = r_ptr_reg + 1'b1;
        end
    end

    assign empty = (w_ptr_reg == r_ptr_reg);

    assign full  = (w_ptr_reg[ADDR_WIDTH-1:0] == r_ptr_reg[ADDR_WIDTH-1:0]) && 
                   (w_ptr_reg[ADDR_WIDTH]     != r_ptr_reg[ADDR_WIDTH]);

endmodule
