//testbench
`timescale 1ns/1ps

module testbench;
  parameter DATA_WIDTH=8;
  reg clk;
  reg rst;
  reg enable;
  reg [DATA_WIDTH-1:0]master_tx;
  reg [DATA_WIDTH-1:0]slave_tx;
  wire master_ready;
  wire slave_done;
  wire [DATA_WIDTH-1:0]master_rx;
  wire [DATA_WIDTH-1:0]slave_rx;
  
  top_module #(.DATA_WIDTH(DATA_WIDTH)) DUT_3(.clk(clk),
                                            .rst(rst),
                                            .enable(enable),
                                            .master_tx(master_tx),
                                            .slave_tx(slave_tx),
                                            .master_ready(master_ready),
                                              .slave_done(slave_done),
                                            .master_rx(master_rx),
                                            .slave_rx(slave_rx));
  
  initial begin
    $dumpfile("wave.vcd");
    $dumpvars;
  end
  
 
 //  Clock Generation (100MHz example)
    always #5 clk = ~clk;

    // Task for SPI Transaction
    // This automates the waiting and pulsing for you
    task send_spi_byte(input [7:0] m_data, input [7:0] s_data);
        begin
            wait(master_ready);      // Ensure master is idle
            master_tx = m_data;
            slave_tx  = s_data;
            #10 enable = 1;          // Pulse Enable for 1 clock cycle
            #10 enable = 0;
            
            wait(slave_done);        // Wait for Slave to finish capture
            wait(master_ready);      // Wait for Master to return to IDLE
            #1;                      // Wait 1ns for registers to stabilize
            
            $display("Time: %0t | Master Sent: %h, Received: %h", $time, m_data, master_rx);
            $display("Time: %0t | Slave Sent: %h, Received: %h", $time, s_data, slave_rx);
            $display("---------");
        end
    endtask

    //Main Stimulus
    initial begin
        // Initialize Signals
        clk = 0;
        rst = 1;
        enable = 0;
        master_tx = 0;
        slave_tx = 0;

        // Reset Sequence
        #20 rst = 0;
        #20;

        // Transaction 1
        send_spi_byte(8'hA5, 8'h3C);

        // Transaction 2
        #50;
        send_spi_byte(8'hFF, 8'h12);

        // Transaction 3
        #50;
        send_spi_byte(8'hFA, 8'h10);

        #100;
        $display("Simulation Finished Successfully.");
        $finish;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule
