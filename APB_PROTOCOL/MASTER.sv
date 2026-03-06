module apb_master(
    input        pclk,
    input        preset_n,
  input          req_psel,   //slave select from master
    input        req_penb,    //
    input        req_start,   //input datas from the axi 
    input        req_write,   //write=1 read=0
  input  [7:0] pwrdata,       //write data
  input  [3:0] pwaddr,        //write address
    
    input        pready,     //to ack slave is busy or not
  input  [7:0] prdata,       //
    
    output reg        psel,
    output reg        penb,
    output reg        pwrite,
    output reg [7:0]  pwdata,
    output reg [3:0]  paddr,
    output reg [7:0]  rdata
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
      IDLE: next_state = (req_start) ? SETUP : IDLE;
      SETUP:  next_state = ACCESS;
      ACCESS: next_state = (pready) ? IDLE : ACCESS;
      default: next_state = IDLE;
    endcase
  end

  // Output logic
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      psel <= 0;
      penb <= 0;
      pwrite <= 0;
      pwdata <= 0;
      paddr <= 0;
      rdata <= 0;
    end
    else begin
      case(present_state)

        IDLE: begin
          psel<= req_psel;
          penb<= req_penb;
          psel <= 0;
          penb <= 0;
        end

        SETUP: begin
          psel <= 1;
          penb <= 0;
          pwrite <= req_write;
          paddr <= pwaddr;
          pwdata <= pwrdata;
        end

        ACCESS: begin
          psel <= 1;
          penb <= 1;

          if(pready) begin
            if(!pwrite)          // READ operation
              rdata <= prdata;   // capture slave data
          end
        end

      endcase
    end
  end

endmodule
