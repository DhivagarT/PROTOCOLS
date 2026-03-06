`timescale 1ns/1ps

module testbench;

  reg tb_pclk;
  reg tb_preset_n;

  reg tb_req_start;
  reg tb_req_write;
  reg tb_psel;
  reg tb_penb;
  reg [7:0] tb_pwrdata;
  reg [3:0] tb_pwraddr;

  wire [7:0] tb_rdata;
  wire tb_pslverr;

  // Instantiate DUT
  top_module dut (
    .pclk(tb_pclk),
    .preset_n(tb_preset_n),
    .req_psel(tb_psel),
    .req_penb(tb_penb),
    .req_start(tb_req_start),
    .req_write(tb_req_write),
    .pwrdata(tb_pwrdata),
    .pwraddr(tb_pwraddr),
    .rdata(tb_rdata),
    .pslverr(tb_pslverr)
  );

  // Clock generation (10ns period)
  always #5 tb_pclk = ~tb_pclk;

  // Dump waves
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);
  end
 initial begin
   tb_psel =0;
   tb_penb= 0;
 end
  initial begin
    // Initialize signals
    tb_pclk      = 0;
    tb_preset_n  = 0;
    tb_req_start = 0;
    tb_req_write = 0;
    tb_pwrdata   = 0;
    tb_pwraddr   = 0;

    // Apply reset
    #15;
    tb_preset_n = 1;


    // WRITE TRANSACTION
    @(negedge tb_pclk);
    tb_pwraddr   = 4'h3;
    tb_pwrdata   = 8'hA5;
    tb_req_write = 1;
    tb_req_start = 1;
    tb_psel = 1;
    tb_penb = 0;

    @(negedge tb_pclk);
    tb_req_start = 0;
    #1 tb_penb = 1;
    // wait some cycles
    #40;

    // READ TRANSACTION
    @(negedge tb_pclk);
    tb_pwraddr   = 4'h3;
    tb_pwrdata   = 4'hBC;
    tb_req_write = 0;
    tb_req_start = 1;
    tb_psel =1;
    tb_penb= 0;
    @(negedge tb_pclk);
    tb_req_start = 0;
    tb_penb= 1;
    #40;

    $finish;
  end

  // Monitor values
  initial begin
    $monitor("TIME=%0t | START=%b WRITE=%b PSEL=%d PENB=%d ADDR=%h WDATA=%h RDATA=%h ERROR=%b",$time,tb_req_start,tb_req_write,tb_psel,tb_penb,tb_pwraddr,tb_pwrdata,tb_rdata,tb_pslverr);
  end

endmodule
