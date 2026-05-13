/* Designed by KS
 * 
 * ps2_interface: receives data through ps2 and outputs one byte key_code
*/

module ps2_interface (
    input logic clk,
    input logic rst_n,

    input logic ps2_clk,
    input logic ps2_data,

    output logic[7:0] key_code,        //byte output with raw key code
    output logic done                  //done bit, 1 when byte is ready 
    );

    logic [10:0] shift_reg;
    logic [3:0] bit_count;
    logic ps2_clk_sync, ps2_clk_prev;
    logic ps2_data_sync;

    logic [1:0] clk_sync_reg, data_sync_reg;

    //synchronise ps2 signals
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            clk_sync_reg <= 2'b11;
            data_sync_reg <= 2'b11;
        end else begin
            clk_sync_reg <= {clk_sync_reg[0], ps2_clk};
            data_sync_reg <= {data_sync_reg[0], ps2_data};
        end
    end
    
    assign ps2_clk_sync = clk_sync_reg[1];
    assign ps2_data_sync = data_sync_reg[1];

    //detect falling edge of ps2_clk
    always_ff @(posedge clk) begin
        ps2_clk_prev <= ps2_clk_sync;
    end

    wire fall_edge = (ps2_clk_prev == 1 && ps2_clk_sync == 0);

    //shift reg logic
    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            bit_count <= '0;
            shift_reg <= '0;
            done <= '0;
            key_code <= '0;
        end else begin
            done <= '0;
            if (fall_edge) begin
                shift_reg <= {ps2_data_sync, shift_reg [10:1]};
                if(bit_count == 10) begin
                    bit_count <= 0;
                    key_code <= {shift_reg[1], shift_reg[2], shift_reg[3], shift_reg[4], shift_reg[5], shift_reg[6], shift_reg[7], shift_reg[8]};
                    done <= 1;
                end else begin
                    bit_count <= bit_count + 1;
                end
            end
        end
    end
endmodule