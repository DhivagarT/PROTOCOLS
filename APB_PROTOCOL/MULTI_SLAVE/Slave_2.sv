module apb_slave2(
    input        pclk,
    input        preset_n,
    input        psel,
    input        penb,
    input        pwrite,
    input  [7:0] pwdata,
    input  [3:0] paddr,
    output reg       pready,
    output reg       pslverr,
    output reg [7:0] prdata
);

  reg [7:0] mem [0:15];

  always @(posedge pclk or negedge preset_n) begin
    if(!preset_n) begin
      pready  <= 0;
      pslverr <= 0;
      prdata  <= 0;
    end
    else begin
      pready  <= 0;
      pslverr <= 0;

      if(psel && penb) begin
        pready <= 1;

        // Example error condition (optional)
        if(paddr > 4'd15)
          pslverr <= 1;
        else begin
          if(pwrite)
            mem[paddr] <= pwdata;
          else
            prdata <= mem[paddr];
        end
      end
    end
  end

endmodule

// module apb_slave_2(input pclk,
//                   input preset_n,
//                    input psel[1],
//                   input s2_penb,
//                    input s2_pwrite,
//                    input [7:0]s2_pwrdata,
//                    input [3:0]s2_paddr,
//                    output reg s2_pready,
//                    output reg s2_pslverr,
//                    output reg s2_prdata
//                   );
  
//   reg [7:0]mem[15:0];
  
//   always@(posedge pclk or negedge preset_n)begin
//     if(!preset_n)begin
//       s2_prdata<=0;
//       s2_pready<=0;
//       s2_pslverr<=0;
//     end else begin
//       s2_pready<=0;
//       s2_pslverr<=0;
//       if(psel[1]&&s2_penb)begin
//         s2_pready<=1;
//         if(s2_pwrite)begin
//           mem[s2_paddr]<=s2_pwrdata;
        

//           if(s2_paddr>4'd15 | s2_pwrdata>8'h31)
//             s2_pslverr<=1;
//           else
//             s2_pslverr<=0;
//         end
//         else
//           s2_prdata<=mem[s2_paddr];
//       end
//     end
//   end
// endmodule
      
        
    
