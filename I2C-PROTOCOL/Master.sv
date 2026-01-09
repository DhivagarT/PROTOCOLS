module master (
    input clk, rst, wr_enb, enable,
    input [6:0] addr,
    input [7:0] data_in,
    inout sda,
    output reg scl, ready, ack_error
);
    // State machine and counters
    reg [3:0] state;
    reg [7:0] count; // Clock divider counter
    reg [3:0] bit_cnt;
    reg [7:0] shift_reg;
    reg sda_out, sda_enb;

    assign sda = sda_enb ? sda_out : 1'bz;

    localparam IDLE=0, START=1, BIT_LOW=2, BIT_HIGH=3, ACK_WAIT=4, STOP=5;
    localparam DIVIDER = 50; // Slows down 50MHz to ~500kHz for stability

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            scl <= 1; ready <= 1; ack_error <= 0;
            sda_enb <= 0; sda_out <= 1;
            count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    ready <= 1;
                    scl <= 1;
                    sda_enb <= 0;
                    if (enable) begin
                        ready <= 0;
                        state <= START;
                        shift_reg <= {addr, ~wr_enb};
                        bit_cnt <= 7;
                        count <= 0;
                    end
                end

                START: begin
                    sda_enb <= 1;
                    sda_out <= 0; // START condition: SDA falls while SCL is high
                    if (count == DIVIDER) begin
                        state <= BIT_LOW;
                        count <= 0;
                    end else count <= count + 1;
                end

                BIT_LOW: begin
                    scl <= 0;
                    sda_out <= shift_reg[bit_cnt];
                    if (count == DIVIDER) begin
                        state <= BIT_HIGH;
                        count <= 0;
                    end else count <= count + 1;
                end

                BIT_HIGH: begin
                    scl <= 1;
                    if (count == DIVIDER) begin
                        count <= 0;
                        if (bit_cnt == 0) state <= ACK_WAIT;
                        else begin
                            bit_cnt <= bit_cnt - 1;
                            state <= BIT_LOW;
                        end
                    end else count <= count + 1;
                end

                ACK_WAIT: begin
                    scl <= 0;
                    sda_enb <= 0; // Release line for Slave ACK
                    if (count == DIVIDER) begin
                        scl <= 1; // Master pulses SCL for ACK
                        if (sda == 0) begin // SLAVE PULLED SDA LOW
                            // If we just sent address, now load data
                            if (shift_reg[7:1] == addr) begin
                                shift_reg <= data_in;
                                bit_cnt <= 7;
                                state <= BIT_LOW;
                            end else state <= STOP;
                        end else begin
                            ack_error <= 1;
                            state <= STOP;
                        end
                        count <= 0;
                    end else count <= count + 1;
                end

                STOP: begin
                    scl <= 0;
                    sda_enb <= 1;
                    sda_out <= 0;
                    if (count == DIVIDER) begin
                        scl <= 1;
                        sda_out <= 1; // STOP condition: SDA rises while SCL is high
                        state <= IDLE;
                    end else count <= count + 1;
                end
            endcase
        end
    end
endmodule



