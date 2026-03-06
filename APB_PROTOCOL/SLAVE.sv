module apb_slave(
    input pclk,
    input preset_n,

  input psel,
    input penb,
  input [7:0]pwdata,
  input [3:0]paddr,
    input pwrite,

    output reg pready,
    output reg pslverr,
  output reg [7:0]prdata
);

  reg [7:0]mem[0:15];
 
  
  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      pready <= 0;
      pslverr <= 0;
      prdata <= 0; 
     
    end
    else begin
      // Default values
      pready <= 0;
      pslverr <= 0;
      
      // ACCESS phase
      if(psel && penb) begin
        pready <= 1;   // ready in one cycle
      
        if(pwrite) begin
          mem[paddr] <= pwdata;   // Write
        end
        else begin
          if(paddr>4'd15 | pwdata>8'h31)  //address mismatch = slaverr=1 ,if addr and data mismatch
            pslverr<=1;
          else
            pslverr<=0;
          
          prdata <= mem[paddr];   // Read
        end
      end
    end
  end

endmodule
