`include "generator.sv"
`include "transmitter.sv"
`include "receiver.sv"


`timescale 1ns/1ps

module uart_top #(
    parameter SYS_CLK = 50000000)
  (
    input clk,
    input rst_n,
    // Configuration
    input [1:0]baud_sel,
    input parity_typ, // Combined: used for both TX and RX
    input parity_enb, // Combined: used for both TX and RX
    
    // Transmitter 
    input tx_start,
    input [7:0]tx_data,
    output tx_line,
    output tx_busy,
    
    // Receiver
    input rx_line,
    output [7:0] rx_data,
    output rx_done,
    output parity_err  // Added to handle the RX error output
);

    wire tx_tick; // 1x Baud pulse
    wire rx_tick; // 16x Baud pulse

    // 1. Baud Rate Generator
    baud_generator #(
        .SYS_CLK(SYS_CLK)
    ) baud_gen_inst (
        .clk(clk),
        .rst_n(rst_n),
        .baud_sel(baud_sel),
        .tx_tick(tx_tick),
        .rx_tick(rx_tick)
    );

    // 2. Transmitter Instance
    transmitter tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_tick(tx_tick),
        .tx_data(tx_data),
        .parity_enb(parity_enb),
        .parity_typ(parity_typ),
        .tx_line(tx_line),
        .busy(tx_busy)
    );

    // 3. Receiver Instance
    receiver rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_line(rx_line),
        .rx_tick(rx_tick),
        .parity_typ(parity_typ), // Mapping parity_typ to internal parity_type
        .parity_enb(parity_enb),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_err(parity_err)   // Correctly connected now
    );

endmodule
