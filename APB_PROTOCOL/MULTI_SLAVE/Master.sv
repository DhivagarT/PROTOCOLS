`include "addr_decoder.sv"

module apb_master(
    input        pclk,
    input        preset_n,

    input  [1:0] req_psel,      // slave select request
    input        req_start,     
    input        req_write,
    input  [7:0] pwrdata,
    input  [3:0] pwaddr,

    input        pready,
    input  [7:0] prdata,

    output reg [1:0] psel,      // NOW 2-bit
    output reg       penb,
    output reg       pwrite,
    output reg [7:0] pwdata,
    output reg [3:0] paddr,
    output reg [7:0] rdata
);

  // Decoder output
  wire [1:0] psel_dec;

  addr_decoder dec(
      .slave_sel(req_psel),
      .psel_dec(psel_dec)
  );

  reg [1:0] present_state, next_state;
  parameter IDLE=2'd0, SETUP=2'd1, ACCESS=2'd2;

  // State register
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n)
      present_state <= IDLE;
    else
      present_state <= next_state;
  end

  // Next state logic
  always @(*) begin
    case(present_state)
      IDLE:   next_state = (req_start) ? SETUP : IDLE;
      SETUP:  next_state = ACCESS;
      ACCESS: next_state = (pready) ? IDLE : ACCESS;
      default: next_state = IDLE;
    endcase
  end

  // Output logic
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      psel   <= 2'b00;
      penb   <= 0;
      pwrite <= 0;
      pwdata <= 0;
      paddr  <= 0;
      rdata  <= 0;
    end
    else begin
      case(present_state)

        IDLE: begin
          psel <= 2'b00;
          penb <= 0;
        end

        SETUP: begin
          psel   <= psel_dec;   // use decoder output
          penb   <= 0;
          pwrite <= req_write;
          paddr  <= pwaddr;
          pwdata <= pwrdata;
        end

        ACCESS: begin
          psel <= psel_dec;
          penb <= 1;

          if(pready) begin
            if(!pwrite)
              rdata <= prdata;
          end
        end

      endcase
    end
  end

endmodule


