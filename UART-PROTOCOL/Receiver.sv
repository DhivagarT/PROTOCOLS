module receiver (
    input clk, rst_n,
    input rx_line, rx_tick,
    input parity_typ, // 0 for Even, 1 for Odd
    input parity_enb,
    output reg [7:0] rx_data,
    output reg rx_done,
    output reg parity_err
);
    parameter IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;
    reg [2:0] state;
    reg [3:0] count;   
    reg [2:0] bit_idx; 
    reg parity_calc;
  
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            rx_done    <= 0;
            rx_data    <= 0;
            count      <= 0;
            bit_idx    <= 0;
            parity_err <= 0;
            parity_calc <= 0;
        end else begin
            rx_done <= 0; 
            
            if (rx_tick) begin
                case (state)
                    IDLE: begin
                        if (rx_line == 0) begin 
                            state <= START;
                            count <= 0;
                        end
                    end

                    START: begin
                        if (count == 7) begin 
                            if (rx_line == 0) begin 
                                state      <= DATA;
                                count      <= 0;
                                bit_idx    <= 0;
                                parity_err <= 0;
                                // Initialize based on type: Even starts at 0, Odd starts at 1
                                parity_calc <= (parity_typ == 1) ? 1'b1 : 1'b0;
                            end else begin
                                state <= IDLE; 
                            end
                        end else begin
                            count <= count + 1;
                        end
                    end

                    DATA: begin
                        if (count == 15) begin 
                            rx_data[bit_idx] <= rx_line; 
                            count            <= 0;
                            parity_calc      <= parity_calc ^ rx_line;
                            if (bit_idx == 7) begin
                                state <= (parity_enb) ? PARITY : STOP;
                            end else begin
                                bit_idx <= bit_idx + 1;
                            end
                        end else begin
                            count <= count + 1;
                        end
                    end
                  
                    PARITY: begin
                        if (count == 15) begin
                            // Check if received bit matches our calculated expected bit
                            if (rx_line != parity_calc)
                                parity_err <= 1;
                            else 
                                parity_err <= 0;
                           
                            state <= STOP;
                            count <= 0;
                        end else begin
                            count <= count + 1;
                        end
                    end

                    STOP: begin
                        if (count == 15) begin 
                            state   <= IDLE;
                            rx_done <= 1; 
                            count   <= 0;
                        end else begin
                            count <= count + 1;
                        end
                    end
                    
                    default: state <= IDLE;
                endcase
            end
        end
    end
endmodule
