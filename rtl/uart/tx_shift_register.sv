/*
 * Designed by KS
 * How it works:
 * 
 *  
 */

 `timescale 1ns / 1ps

 module tx_shift_register (
     input  logic       clk,         
     input  logic       rst_n,       
     input  logic       tx_start,    // High to load new data and start sending
     input  logic       baud_tick,   // 16x baud tick
     input  logic [7:0] tx_data,     // 8-bit byte to transmit
     output logic       tx_serial,   
     output logic       tx_done      
 );
 
     // TX state machine states
     typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
     state_t state_reg, state_next;
 
     logic [7:0] shift_reg, shift_next;
     logic [3:0] tick_counter, tick_next; // Counts 16 ticks per bit
     logic [2:0] bit_counter, bit_next;   // Counts 8 data bits
     logic       tx_out_reg, tx_out_next;
 
     assign tx_serial = tx_out_reg;
 
     always_ff @(posedge clk or negedge rst_n) begin
         if (!rst_n) begin
             state_reg    <= IDLE;
             shift_reg    <= '0;
             tick_counter <= '0;
             bit_counter  <= '0;
             tx_out_reg   <= 1'b1; // Idle line is high
         end else begin
             state_reg    <= state_next;
             shift_reg    <= shift_next;
             tick_counter <= tick_next;
             bit_counter  <= bit_next;
             tx_out_reg   <= tx_out_next;
         end
     end
 
     always_comb begin
         state_next    = state_reg;
         shift_next    = shift_reg;
         tick_next     = tick_counter;
         bit_next      = bit_counter;
         tx_out_next   = tx_out_reg;
         tx_done       = 1'b0;
 
         case (state_reg)
             IDLE: begin
                 tx_out_next = 1'b1; 
                 if (tx_start) begin
                     shift_next = tx_data;
                     tick_next  = '0;
                     state_next = START;
                 end
             end
 
             START: begin
                 tx_out_next = 1'b0; 
                 if (baud_tick) begin
                     if (tick_counter == 15) begin
                         tick_next  = '0;
                         bit_next   = '0;
                         state_next = DATA;
                     end else begin
                         tick_next = tick_counter + 1'b1;
                     end
                 end
             end
 
             DATA: begin
                 tx_out_next = shift_reg[0]; 
                 if (baud_tick) begin
                     if (tick_counter == 15) begin
                         tick_next  = '0;
                         shift_next = {1'b0, shift_reg[7:1]}; 
                         if (bit_counter == 7) begin
                             state_next = STOP;
                         end else begin
                             bit_next = bit_counter + 1'b1;
                         end
                     end else begin
                         tick_next = tick_counter + 1'b1;
                     end
                 end
             end
 
             STOP: begin
                 tx_out_next = 1'b1; 
                 if (baud_tick) begin
                     if (tick_counter == 15) begin
                         tick_next  = '0;
                         tx_done    = 1'b1;
                         state_next = IDLE;
                     end else begin
                         tick_next = tick_counter + 1'b1;
                     end
                 end
             end
         endcase
     end
 endmodule