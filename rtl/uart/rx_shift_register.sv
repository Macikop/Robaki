/*
 * Designed by KS
 * How it works:
 * 
 */

 `timescale 1ns / 1ps

module rx_shift_register (
    input logic     clk,
    input logic     rst_n,
    input logic     rx_serial,
    input logic     baud_tick,
    output logic    rx_ready,
    output logic[7:0]   rx_data
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state_reg, state_next;

    logic rx_sync0, rx_sync1;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rx_sync0 <= 1'b1;
            rx_sync1 <= 1'b1;
        end else begin
            rx_sync0 <= rx_serial;
            rx_sync1 <= rx_sync0;
        end
    end

    logic [3:0] tick_counter, tick_next;
    logic [2:0] bit_counter, bit_next;
    logic [7:0] d_reg, d_next;

    assign rx_data = d_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            state_reg <= IDLE;
            tick_counter <= '0;
            bit_counter <= '0;
            d_reg <= '0;
        end else begin
            state_reg <= state_next;
            tick_counter <= tick_next;
            bit_counter <= bit_next;
            d_reg <= d_next;
        end
    end

    always_comb begin
        state_next = state_reg;
        tick_next = tick_counter;
        bit_next = bit_counter;
        d_next = d_reg;
        rx_ready = 1'b0;

        case (state_reg)
            IDLE: begin
                if(!rx_sync1) begin
                    state_next = START;
                    tick_next = '0;
                end
            end

            START: begin
                if(baud_tick) begin
                    if(tick_counter == 7) begin
                        tick_next = '0;
                        bit_next = '0;
                        state_next = DATA;
                    end else begin
                        tick_next = tick_counter + 1'b1;
                    end
                end 
            end

            DATA: begin
                if(baud_tick) begin
                    if(tick_counter == 15) begin
                        tick_next = '0;
                        d_next = {rx_sync1, d_reg[7:0]};
                        if(bit_counter == 7) begin
                            state_next = STOP;
                        end else begin
                            bit_next = bit_counter + 1'b1;
                        end
                    end else begin
                        tick_next = tick_counter + 1'b1;
                    end
                end
            end

            STOP:
            if(baud_tick) begin
                if(tick_counter == 15) begin
                    rx_ready = 1'b1;
                    state_next = IDLE;
                end else begin
                    tick_next = tick_counter + 1'b1;
                end
            end
        endcase
    end     
endmodule