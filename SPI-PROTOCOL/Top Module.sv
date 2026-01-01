`include "master.sv"
`include "slave.sv"

module top_module #(parameter DATA_WIDTH=8) (
    input clk,
    input rst,
    input enable,      // Start signal for Master
    input [DATA_WIDTH-1:0]master_tx,   // Data Master sends to Slave
    input [DATA_WIDTH-1:0]slave_tx,    // Data Slave sends to Master
    
    output master_ready,// Master is ready for next byte
    output slave_done,  // Slave has finished receiving
    output [DATA_WIDTH-1:0]master_rx,   // Data Master received from Slave
    output [DATA_WIDTH-1:0]slave_rx     // Data Slave received from Master
);
  
    // Internal SPI Bus Wires (These connect the two modules)
    // They are NOT ports of the top module anymore
    wire sclk;
    wire ss;
    wire mosi;
    wire miso;

    // MASTER INSTANCE
    master #(.DATA_WIDTH(DATA_WIDTH)) DUT_1(
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .data_in(master_tx),// Input from top
        .data_out(master_rx),// Output to top
        .ready(master_ready),// Output to top
        .sclk(sclk),         // Drive internal wire
        .ss(ss),            // Drive internal wire
        .mosi(mosi),        // Drive internal wire
        .miso(miso)         // Read internal wire
    );

    // SLAVE INSTANCE
    slave #(.DATA_WIDTH(DATA_WIDTH)) DUT_2(
      .sclk(sclk),               // Read internal wire
      .ss(ss),                 // Read internal wire
        .mosi(mosi),            // Read internal wire
        .miso(miso),            // Drive internal wire
        .data_in(slave_tx),     // Input from top
        .data_out(slave_rx),    // Output to top
        .done(slave_done)       // Output to top
    );

endmodule
