`include "Master.sv"
`include "Slave.sv"

module top
  (
    input  pclk,
    input  presetn,

    // driven from testbench
    input  start,
    input  [7:0] tb_paddr,
    input  [7:0] tb_pwdata
  );

  // APB bus wires
  wire [7:0] paddr;
  wire [7:0] pwdata;
  wire [7:0] prdata;
  wire pwrite;
  wire penable;
  wire psel;
  wire pready;
  wire pslverr;

  // MASTER
  master dut1 (
    .pclk (pclk),
    .presetn (presetn),
    .start (start),
    .paddr(tb_paddr),
    .pwdata(tb_pwdata),
    .pready(pready),

    .pwrite(pwrite),
    .penable(penable),
    .psel(psel),
    .addr_in(),        // optional
    .data_in()         // optional
  );

  // SLAVE
  slave dut2 (
    .pclk (pclk),
    .presetn(presetn),
    .paddr (paddr),
    .pwdata (pwdata),
    .pwrite (pwrite),
    .penable (penable),
    .psel (psel),

    .pready (pready),
    .prdata (prdata),
    .pslverr(pslverr)
  );

endmodule
