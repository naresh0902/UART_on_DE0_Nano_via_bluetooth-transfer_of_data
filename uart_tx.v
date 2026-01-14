module uart_tx (
    input  wire clk,        // 50 MHz
    input  wire reset_n,    // Active low reset (DE0 Nano has buttons)
    input  wire tx_start,
    input  wire [7:0] data,
    output reg  tx,
    output reg  tx_done
);

localparam integer CLKS_PER_BIT = 434;
localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;

reg [1:0] state;
reg [8:0] clk_cnt;
reg [2:0] bit_idx;
reg [7:0] data_buffer; // Buffer to prevent data corruption mid-transmission

always @(posedge clk or negedge reset_n) begin
  if (!reset_n) begin
    state   <= IDLE;
    tx     <= 1'b1;
    tx_done  <= 1'b0;
    clk_cnt  <= 0;
    bit_idx  <= 0;
    data_buffer <= 8'd0;
  end else begin
    case (state)

      IDLE: begin
        tx   <= 1'b1;
        tx_done <= 1'b0;
        clk_cnt <= 0;
        bit_idx <= 0;
        if (tx_start) begin
          data_buffer <= data;
          state   <= START;
        end
      end

      START: begin
        tx   <= 1'b0;
        tx_done <= 1'b0;
        if (clk_cnt == CLKS_PER_BIT-1) begin
          clk_cnt <= 0;
          state <= DATA;
        end else clk_cnt <= clk_cnt + 1;
      end

      DATA: begin
        tx <= data_buffer[bit_idx];
        if (clk_cnt == CLKS_PER_BIT-1) begin
          clk_cnt <= 0;
          if (bit_idx == 7) state <= STOP;
          else bit_idx <= bit_idx + 1;
        end else clk_cnt <= clk_cnt + 1;
      end

      STOP: begin
        tx <= 1'b1;
        if (clk_cnt == CLKS_PER_BIT-1) begin
          clk_cnt <= 0;
          bit_idx <= 0;   // ✅ FIX
          tx_done <= 1'b1;
          state <= IDLE;
        end else clk_cnt <= clk_cnt + 1;
      end

    endcase
  end
end
endmodule
