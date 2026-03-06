
  
  
`include "master.sv"
`include "slave_1.sv"

module top_module(
  input pclk,
  input preset_n,

  // User interface
  input req_start,
  input req_write,
  input req_psel,
  input req_penb,
  input [7:0] pwrdata,
  input [3:0] pwraddr,
  
  output [7:0]rdata,
  output pslverr
  
);

  // Internal APB bus signals
  wire [1:0]psel;
  wire penb;
  wire pwrite;
  wire [7:0] pwdata;
  wire [3:0] paddr;
  wire [7:0] prdata;
  wire pready;

  // MASTER
  apb_master dut1(
    .pclk(pclk),
    .preset_n(preset_n),
    .req_psel(req_psel),
    .req_penb(req_penb),
    .req_start(req_start),
    .req_write(req_write),
    .pwrdata(pwrdata),
    .pwaddr(pwraddr),

    .pready(pready),
    .prdata(prdata),

    .psel(psel),
    .penb(penb),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .paddr(paddr),
    .rdata(rdata)
  );

  // SLAVE
  apb_slave dut2(
    .pclk(pclk),
    .preset_n(preset_n),

    .psel(psel),
    .penb(penb),
    .pwrite(pwrite),
    .pwdata(pwdata),
    .paddr(paddr),

    .pready(pready),
    .pslverr(pslverr),
    .prdata(prdata)
  );

  
  
endmodule
