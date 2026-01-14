
FPGA project enabling wireless communication between smartphone and FPGA via HC-05 Bluetooth. Receives data bytes through UART and echoes them back instantly. Perfect for testing Bluetooth connectivity and UART setups. Works with any Bluetooth terminal app. Modular design, beginner-friendly, adaptable to any FPGA platform.

# UART Echo with HC-05 Bluetooth Module

A simple FPGA-based UART echo system that receives data from a smartphone via HC-05 Bluetooth module and sends the same data back as confirmation.



## Overview

This project implements a basic communication loop between a smartphone and an FPGA board using a HC-05 Bluetooth module. Any data sent from the phone is immediately echoed back, making it useful for testing Bluetooth connectivity and UART communication.

## Features

- Wireless communication via HC-05 Bluetooth module
- Real-time data echo functionality
- Simple start/stop command interface
- Configurable UART baud rate (typically 9600 or 115200)

## Hardware Requirements

- FPGA Development Board (with clock input)
- HC-05 Bluetooth Module
- Connecting wires
- Smartphone with Bluetooth terminal app

## Hardware Connections

### HC-05 to FPGA
```
HC-05 TX  → FPGA RX
HC-05 RX  → FPGA TX
HC-05 VCC → 5V/3.3V (check your module specs)
HC-05 GND → GND
```

### Pin Assignment
You need to assign these pins in your constraint file:
- `clk` - System clock (typically 50 MHz)
- `rst_n` - Active-low reset button
- `rx` - UART receive from HC-05
- `tx` - UART transmit to HC-05

## Software Requirements

### FPGA Development
- Vivado/Quartus (depending on your FPGA)
- UART RX and TX modules (not included in this repository)

### Smartphone App
Any Bluetooth serial terminal app:
- **Android:** "Serial Bluetooth Terminal" or "Bluetooth Terminal"
- **iOS:** "BLE Terminal" or similar

## Module Description

### uart_echo.v

The main module that implements the echo functionality:

**Inputs:**
- `clk` - System clock
- `rst_n` - Active-low reset
- `rx` - UART receive line

**Outputs:**
- `tx` - UART transmit line

**Functionality:**
1. Waits for incoming data on RX line
2. When complete byte is received (`rx_done` signal)
3. Copies received data and triggers transmission
4. Sends the same data back through TX line

## How to Use

### 1. FPGA Setup
1. Synthesize and program the FPGA with the `uart_echo` module
2. Ensure UART modules are configured for correct baud rate (match HC-05 settings)
3. Connect HC-05 module as shown above
4. Power on the system

### 2. HC-05 Configuration
The HC-05 module should be configured with:
- Baud rate: 9600 or 115200 (match your UART modules)
- Default name: HC-05
- Default PIN: 1234 or 0000

### 3. Smartphone Connection
1. Enable Bluetooth on your phone
2. Pair with HC-05 module (PIN: 1234)
3. Open Bluetooth terminal app
4. Connect to HC-05 device

### 4. Testing
1. Send any byte from your phone (e.g., 0xAA, 0x55, or ASCII characters)
2. You should receive the same byte back
3. This confirms bidirectional communication is working

### Example Commands
- Send `0xAA` (170 in decimal) - typically used as start command
- Send `0x55` (85 in decimal) - alternative test byte
- Send ASCII characters like 'A', 'B', 'C'

## Timing Specifications

- **System Clock:** 50 MHz (typical)
- **UART Baud Rate:** 9600 or 115200 (configurable in UART modules)
- **Echo Latency:** ~1-2 ms (depending on clock frequency)

## Troubleshooting

### No Response from FPGA
- Check HC-05 connections (TX/RX may be swapped)
- Verify baud rate matches between FPGA and HC-05
- Ensure reset is released (rst_n should be high)
- Check power supply to HC-05

### Garbled Data
- Baud rate mismatch - reconfigure HC-05 or UART modules
- Check clock frequency is correct

### Cannot Pair with HC-05
- HC-05 LED should be blinking (pairing mode)
- Try default PIN: 1234 or 0000
- Reset HC-05 module if needed

## Dependencies

This module requires separate UART RX and TX modules:
- `uart_rx.v` - UART receiver module
- `uart_tx.v` - UART transmitter module

These modules should implement standard UART protocol with configurable baud rate.

## Future Enhancements

- Add command parser for multiple commands
- Implement error checking (parity/checksum)
- Add status LED indicators
- Support for longer message packets
- Flow control implementation

## License

This project is open source and available for educational and commercial use.

## Author

Created for FPGA-based Bluetooth communication testing.

## Version History

- **v1.0** - Initial release with basic echo functionality
