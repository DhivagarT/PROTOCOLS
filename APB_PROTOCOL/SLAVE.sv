module slave
  (input pclk,
   input presetn,
   
   input pwrite,
   input penable,
   input psel,
   input [7:0]pwdata,
   input [7:0]paddr,
   
   output reg pready,
   output reg [7:0]prdata,
   output reg pslverr
  );
  
//   parameter IDLE=0,SETUP=1,ACCESS=2;
  
//   reg [2:0]state;
   reg [7:0]mem[0:255];
  
  
always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    pready<=0;
    prdata<=0;
    pslverr<=0;
  end
  else begin
    // default outputs
    pready<=0;
    pslverr<=0;

    // ACCESS phase
    if (psel&&penable) begin
      pready<=1;   // complete transfer
      if(pwrite)begin
        mem[paddr] <= pwdata;
      end
      else begin
        prdata <= mem[paddr];
      end
    end
  end
end


endmodule
