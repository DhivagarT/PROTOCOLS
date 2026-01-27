          
module master
  (input pclk,
   input presetn,
   input start,
   input [7:0]paddr,
   input [7:0]pwdata,
//    input [7:0]prdata,
   input pready,
   
   output reg pwrite,
   output reg penable,
   output reg psel,
   output reg [7:0]addr_in,
   output reg [7:0]data_in,
//    output reg pslverr

  );

  
  parameter IDLE=0,SETUP=1,ACCESS=2;
  
  reg [1:0]state;
  
  always@(posedge pclk or negedge presetn)begin
    if(!presetn)begin
      pwrite<=0;
      penable<=0;
      psel<=0;
      addr_in<=0;
      data_in<=0;
      state<=IDLE;
      
    end else begin
      
      case(state)
        IDLE:begin
         
          penable<=0;
          psel<=0;
          pwrite<=0;
          if(start)
          state<=SETUP;
//           else
//             state<=IDLE;
          
        end
        
        SETUP:begin
          pwrite<=1;
          penable<=0;
          data_in<=pwdata;
          addr_in<=paddr;
          psel<=1;
          state<=ACCESS;
        end
        
        ACCESS:begin
          penable<=1;
          psel<=1;
          pwrite<=1;
          if(pready)begin //transaction completed
             penable<=0;
             psel<=0;
             state<=IDLE;
          end
        end
        default:state<=IDLE;
      endcase
    end
  end
endmodule
          
  
            
          
          
      
      
      
