`timescale 1ns/1ps

module baud_generator #(
    parameter SYS_CLK = 50000000
) (
    input clk, rst_n,
    input [1:0] baud_sel,
    output tx_tick, // 1-cycle pulse at baud rate
    output rx_tick  // 1-cycle pulse at 16x baud rate
);
    reg [31:0] rx_limit;
    reg [31:0] count_rx;
    reg [31:0] tx_limit;
    reg [31:0]  tx_count;
  

    // Set limit for 16x oversampling
    always @(*) begin
        case(baud_sel)
            2'b00: rx_limit = SYS_CLK / (2400 * 16);
            2'b01: rx_limit = SYS_CLK / (4800 * 16);
            2'b10: rx_limit = SYS_CLK / (9600 * 16);
          2'b11: rx_limit = SYS_CLK / (19200 * 16);
            default: rx_limit = SYS_CLK / (9600 * 16);
        endcase
    end
    always@(*)begin
      case(baud_sel)
        2'b00: tx_limit = SYS_CLK / 2400;
        2'b01: tx_limit = SYS_CLK / 4800;
        2'b10: tx_limit = SYS_CLK / 9600;
        2'b11: tx_limit = SYS_CLK / 19200;
        default: tx_limit = SYS_CLK / 9600;
      endcase
    end

    // RX Tick Generation
    assign rx_tick = (count_rx == rx_limit - 1);
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
          count_rx <= 0;
        else if (rx_tick)
          count_rx <= 0;
        else 
          count_rx <= count_rx + 1;
    end

//     // TX Tick Generation (RX Tick divided by 16)
  //     assign tx_tick = (rx_tick && (tx_count == 15));    //by using only rx_limit case

//     always @(posedge clk or negedge rst_n) begin
//         if (!rst_n) 
//           tx_count <= 0;
//         else if (rx_tick) 
//           tx_count <= tx_count + 1;
//     end
      assign tx_tick = (tx_count == tx_limit -1);
      always@(posedge clk or negedge rst_n)begin
        if(!rst_n)
          tx_count<= 0;
        else if(tx_tick)
          tx_count <=0;
        else
          tx_count <= tx_count+1;
      end
  
endmodule
