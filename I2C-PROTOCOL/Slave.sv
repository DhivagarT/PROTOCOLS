`timescale 1ns/1ps

module slave #(
    parameter SLAVE_ADDR = 7'h50
)(
    input rst,
    input scl,
    inout sda,
    output reg [7:0] data_out,
    output reg data_valid
);

    // Open-drain SDA
    reg sda_enb;
    reg sda_out;
    assign sda = sda_enb ? sda_out : 1'bz;

    // FSM States
    typedef enum logic [2:0] {
        IDLE     = 3'd0,
        ADDR     = 3'd1,
        ADDR_ACK = 3'd2,
        DATA     = 3'd3,
        DATA_ACK = 3'd4
    } state_t;

    state_t state;
    reg [7:0] shift_reg;
    reg [3:0] bit_cnt;
    
    // START condition detection must be asynchronous to the clock
    reg start_reg;
    always @(negedge sda) begin
        if (scl) start_reg <= 1'b1;
    end

    // --- Main FSM: Sampling on POSEDGE ---
    always @(posedge scl or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            bit_cnt    <= 0;
            data_valid <= 0;
            data_out   <= 0;
            start_reg  <= 0;
        end else begin
            case (state)
                IDLE: begin
                    data_valid <= 0;
                    if (start_reg) begin
                        state     <= ADDR;
                        bit_cnt   <= 7;
                        start_reg <= 0; // Clear start flag
                    end
                end

                ADDR: begin
                    shift_reg[bit_cnt] <= sda;
                    if (bit_cnt == 0) state <= ADDR_ACK;
                    else bit_cnt <= bit_cnt - 1;
                end

                ADDR_ACK: begin
                    if (shift_reg[7:1] == SLAVE_ADDR && shift_reg[0] == 1'b0) begin
                        state   <= DATA;
                        bit_cnt <= 7;
                    end else begin
                        state <= IDLE;
                    end
                end

                DATA: begin
                    shift_reg[bit_cnt] <= sda;
                    if (bit_cnt == 0) state <= DATA_ACK;
                    else bit_cnt <= bit_cnt - 1;
                end

                DATA_ACK: begin
                    data_out   <= shift_reg;
                    data_valid <= 1;
                    state      <= IDLE;
                end
            endcase
        end
    end

    // --- ACK Generation: Driving on NEGEDGE ---
    // This prevents race conditions by changing SDA while SCL is LOW
    always @(negedge scl or posedge rst) begin
        if (rst) begin
            sda_enb <= 0;
            sda_out <= 1;
        end else begin
            if (state == ADDR_ACK && shift_reg[7:1] == SLAVE_ADDR) begin
                sda_enb <= 1;
                sda_out <= 0; // Drive ACK
            end else if (state == DATA_ACK) begin
                sda_enb <= 1;
                sda_out <= 0; // Drive ACK
            end else begin
                sda_enb <= 0; // Release line
            end
        end
    end

endmodule
