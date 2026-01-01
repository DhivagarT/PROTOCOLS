module master#(parameter DATA_WIDTH=8)
  (input clk,
   input rst,
   input enable,
   input [DATA_WIDTH-1:0]data_in,
   output reg[DATA_WIDTH-1:0]data_out,
   output reg ready,
   
   output reg mosi,
   input  miso,
   output reg sclk,    //mode=0 cpol=0,cpha=0
   output reg ss
   
  );
  
  parameter [2:0] IDLE=0,START=1,TOGGLE_LOW=2,TOGGLE_HIGH=3,DONE=4;
  parameter LOG_DATA=$clog2(DATA_WIDTH);
  
  reg [2:0]state;
  reg [DATA_WIDTH-1:0]shift_reg;
  reg [LOG_DATA:0]bit_index;
  
  always@(posedge clk or posedge rst)begin
    if(rst)begin
      
      state<=IDLE;
      sclk<=0;
      ss<=1;
      shift_reg<=0;
      data_out<=0;
      //enable<=0;
    end
    else begin
      case(state)
        IDLE:
          begin
            sclk<=0;
            ss<=1;
            ready<=1;
            if(enable)begin
              shift_reg<=data_in;
              bit_index<=DATA_WIDTH-1;
              ready<=0;
              state<=START;
            end
          end
        
        START:
          begin
            ss<=0;
            state<=TOGGLE_LOW;
          end
        
        TOGGLE_LOW:
          begin
            sclk<=0;      //data transfering at falling edge  //CPHA=0
            mosi <= shift_reg[bit_index];
            state<=TOGGLE_HIGH;
          end
        
        TOGGLE_HIGH:
          begin
            sclk<=1;        //sampling data at rising edge
           // shift_reg[bit_index] <= miso;
            data_out[bit_index]<=miso;
            if(bit_index==0)
              state<=DONE;
            else begin
              bit_index<=bit_index-1;
              state<=TOGGLE_LOW;
            end
          end
        
        DONE:
          begin
            sclk<=0;
            ss<=1;
          //  data_out<=shift_reg;
            ready<=1;
            state<=IDLE;
          end
        
        default:state<=IDLE;
      endcase
    end
  end
endmodule
      
            

              
            
            
              
      
  
  
