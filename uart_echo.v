module uart_echo (
  input  wire clk,
  input  wire rst_n,

  // UART (connects to HC-05 Bluetooth module)
  input  wire rx,
  output wire tx
);

  // UART signals
  wire [7:0] rx_data;
  wire rx_done;
  reg  tx_start;
  reg  [7:0] tx_data;

  // UART RX - receives data from phone via HC-05
  uart_rx RX (
    .clk(clk),
    .reset_n(rst_n),
    .rx(rx),
    .rx_msg(rx_data),
    .rx_complete(rx_done)
  );

  // UART TX - sends data back to phone via HC-05
  uart_tx TX (
    .clk(clk),
    .reset_n(rst_n),
    .tx_start(tx_start),
    .data(tx_data),
    .tx(tx)
  );

  // Echo logic: When data is received, send it back
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      tx_start <= 0;
      tx_data <= 0;
    end else begin
      if (rx_done) begin
        tx_data <= rx_data;  // Copy received data
        tx_start <= 1;       // Trigger transmission
      end else begin
        tx_start <= 0;       // Clear start signal
      end
    end
  end

endmodule
