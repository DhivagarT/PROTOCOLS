module slave #(parameter DATA_WIDTH=8)
  (input sclk,
   input ss,
   input mosi,
   output wire miso,      // Changed to wire
   output reg done,
   input [DATA_WIDTH-1:0] data_in,
   output reg [DATA_WIDTH-1:0] data_out
   );

  reg [DATA_WIDTH-1:0] shift_reg;
  reg [$clog2(DATA_WIDTH):0] bit_index;

  // Use assign for MISO to ensure bit 7 is ready before the first clock
  assign miso = (!ss) ? data_in[bit_index] : 1'bz;

  always @(posedge sclk or posedge ss) begin
    if (ss) begin
      done <= 0;
      bit_index <= DATA_WIDTH - 1;
      shift_reg <= 0;
    end else begin
      // Store current bit
      shift_reg[bit_index] <= mosi;
      
      if (bit_index == 0) begin
        done <= 1;
        // Capture all bits including the current mosi bit
        data_out <= (shift_reg | (mosi << 0)); 
        bit_index <= DATA_WIDTH - 1;
      end else begin
        bit_index <= bit_index - 1;
        done <= 0;
      end
    end
  end
endmodule
