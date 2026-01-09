`timescale 1ns/1ps

`include "master.sv"
`include "slave.sv"

module i2c_top (
    input clk,
    input rst,
    input enable,
    input wr_enb,
    input [6:0] addr,
    input [7:0] data_in,
    output [7:0] data_out_slave,
    output data_valid_slave,
    output scl_master,
    inout sda_bus,
    output ready_master,
    output ack_error_master
);

    // Internal wires for SCL/SDA
    wire scl;
    wire sda;

    // Connect master to top SDA/SCL
    assign sda_bus = sda;  // bidirectional line

    // Instantiate I2C Master
    master u_master (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .wr_enb(wr_enb),
        .addr(addr),
        .data_in(data_in),
        .sda(sda),
        .scl(scl),
        .ready(ready_master),
        .ack_error(ack_error_master)
    );

    // Instantiate I2C Slave
    slave #(.SLAVE_ADDR(7'h50)) u_slave (
        .rst(rst),
        .scl(scl),
        .sda(sda),
        .data_out(data_out_slave),
        .data_valid(data_valid_slave)
    );

    // Optional: expose SCL for external monitoring
    assign scl_master = scl;

endmodule
