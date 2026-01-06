module transmitter (
    input clk, rst_n,
    input tx_start, tx_tick,
    input [7:0] tx_data,
    input parity_enb,
    input parity_typ, // 0 for Even, 1 for Odd
    output reg tx_line, busy
);
    parameter IDLE=0, START=1, DATA=2, PARITY=3, STOP=4;
    reg [2:0] state;
  
    reg [7:0] data_buf;
    reg [2:0] bit_idx;
    reg parity_bit;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            tx_line <= 1;
            busy <= 0;
            parity_bit <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_line <= 1;
                    busy <= 0;
                    if (tx_start) begin
                        data_buf <= tx_data;
                        state <= START;
                        busy <= 1;
                        // Corrected: Calculate parity of the input data
                        parity_bit <= ^tx_data; 
                    end
                end
              
                START: if (tx_tick) begin
                    tx_line <= 0; // Start bit
                    state <= DATA;
                    bit_idx <= 0;
                end
              
                DATA: if (tx_tick) begin
                    tx_line <= data_buf[bit_idx];
                    if (bit_idx == 7) 
                        state <= parity_enb ? PARITY : STOP;
                    else 
                        bit_idx <= bit_idx + 1;
                end
                
                PARITY: if (tx_tick) begin // Added tick check for timing
                    // parity_typ 0 = Even, 1 = Odd
                    tx_line <= (parity_typ == 0) ? parity_bit : ~parity_bit;
                    state <= STOP;
                end
              
                STOP: if (tx_tick) begin
                    tx_line <= 1; // Stop bit
                    state <= IDLE;
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
