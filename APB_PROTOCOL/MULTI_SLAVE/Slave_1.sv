module apb_slave1(
    input        pclk,
    input        preset_n,

    input        psel,        // single bit
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
      // default values
      pready  <= 0;
      pslverr <= 0;

      if(psel && penb) begin
        pready <= 1;

        // Address error check
        if(paddr > 4'd15) begin
          pslverr <= 1;
        end
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
