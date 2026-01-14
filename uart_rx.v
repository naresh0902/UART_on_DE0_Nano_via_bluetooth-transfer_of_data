module uart_rx (
  input wire clk,    // 50 MHz
  input wire reset_n,  // Active-low reset
  input wire rx,     // UART RX pin
  output reg [7:0] rx_msg,
  output reg rx_complete
);

  // Baud parameters for 115200 @ 50 MHz
  localparam integer CLKS_PER_BIT = 434;
  localparam integer HALF_BIT  = CLKS_PER_BIT / 2;

  // FSM states
  localparam IDLE = 2'd0;
  localparam START = 2'd1;
  localparam DATA = 2'd2;
  localparam STOP = 2'd3;

  reg [1:0] state;
  reg [8:0] clk_cnt;
  reg [2:0] bit_idx;
  reg [7:0] rx_shift;

  // --------------------------------------------------
  // 2-FF synchronizer for RX (metastability protection)
  // --------------------------------------------------
  reg rx_ff1, rx_ff2;
  always @(posedge clk) begin
    rx_ff1 <= rx;
    rx_ff2 <= rx_ff1;
  end
  wire rx_reg = rx_ff2;

  // --------------------------------------------------
  // UART RX FSM
  // --------------------------------------------------
  always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
      state   <= IDLE;
      clk_cnt  <= 0;
      bit_idx  <= 0;
      rx_shift  <= 0;
      rx_msg   <= 0;
      rx_complete <= 0;
    end else begin
      case (state)

        // -------------------
        // IDLE: wait for start bit
        // -------------------
        IDLE: begin
          rx_complete <= 1'b0;
          clk_cnt  <= 0;
          bit_idx  <= 0;
          if (rx_reg == 1'b0)   // start bit detected
            state <= START;
        end

        // -------------------
        // START: validate mid-bit
        // -------------------
        START: begin
          if (clk_cnt == HALF_BIT) begin
            if (rx_reg == 1'b0) begin
              clk_cnt <= 0;
              state <= DATA;
            end else begin
              state <= IDLE; // false start
            end
          end else
            clk_cnt <= clk_cnt + 1;
        end

        // -------------------
        // DATA: receive 8 bits (LSB first)
        // -------------------
        DATA: begin
          if (clk_cnt == CLKS_PER_BIT-1) begin
            clk_cnt <= 0;
            rx_shift <= {rx_reg, rx_shift[7:1]};

            if (bit_idx == 3'd7) begin
              bit_idx <= 0;
              state <= STOP;
            end else
              bit_idx <= bit_idx + 1;
          end else
            clk_cnt <= clk_cnt + 1;
        end

        // -------------------
        // STOP: validate stop bit
        // -------------------
        STOP: begin
          if (clk_cnt == CLKS_PER_BIT-1) begin
            clk_cnt <= 0;
            if (rx_reg == 1'b1) begin
              rx_msg   <= rx_shift;
              rx_complete <= 1'b1; // one-cycle pulse
            end
            state <= IDLE;
          end else
            clk_cnt <= clk_cnt + 1;
        end

      endcase
    end
  end

endmodule
