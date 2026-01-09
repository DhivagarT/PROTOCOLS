`timescale 1ns/1ps

module tb_i2c;

    // Clock and reset
    reg clk;
    reg rst;

    // Master control signals
    reg enable;
    reg wr_enb;
    reg [6:0] addr;
    reg [7:0] data_in;

    // Wires from top module
    wire [7:0] data_out_slave;
    wire data_valid_slave;
    wire scl_master;
    wire sda_bus;
    wire ready_master;
    wire ack_error_master;

    // Instantiate the top module
    i2c_top uut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .wr_enb(wr_enb),
        .addr(addr),
        .data_in(data_in),
        .data_out_slave(data_out_slave),
        .data_valid_slave(data_valid_slave),
        .scl_master(scl_master),
        .sda_bus(sda_bus),
        .ready_master(ready_master),
        .ack_error_master(ack_error_master)
    );

    // Clock generation
    initial clk = 0;
    always #10 clk = ~clk; // 50 MHz clock

    // Timeout to prevent hang
    initial begin
        #1000000;
        $display("Simulation timeout!");
        $finish;
    end

   initial begin
        // 1. Reset the system
        rst = 1; enable = 0; wr_enb = 1;
        addr = 7'h50; data_in = 8'hA5;
        #100 rst = 0;
        #100;

        // 2. Start First Transaction
        $display("[T=%0t] --- Starting First Byte ---", $time);
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable = 0;

        // 3. Wait specifically for the Slave to signal it got data
        // We give it a generous timeout using fork/join_any
        fork
            begin
                wait(data_valid_slave == 1);
                $display("Time=%0t ns | Master sent: 0x%h | Slave received: 0x%h",
                          $time, data_in, data_out_slave);
            end
            begin
                #500000; // 0.5ms timeout
                $display("TIMEOUT: Slave never received the first byte!");
            end
        join_any

        // 4. Wait for Master to be ready for the next command
        wait(ready_master == 1);
        #1000; // Small gap between transactions

        // 5. Start Second Transaction
        data_in = 8'h5A;
        $display("[T=%0t] --- Starting Second Byte ---", $time);
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable = 0;

        wait(data_valid_slave == 1);
        $display("Time=%0t ns | Master sent: 0x%h | Slave received: 0x%h",
                  $time, data_in, data_out_slave);

        #1000;
        $finish;
    end
endmodule
