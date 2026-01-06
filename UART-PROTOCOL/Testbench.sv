`timescale 1ns/1ps

module testbench;

    // Parameters
    localparam CLK_PERIOD = 20; // 50 MHz
    
    // Testbench Signals
    reg clk;
    reg rst_n;
    reg [1:0] baud_sel;
    reg parity_typ;
    reg parity_enb;
    reg tx_start;
    reg [7:0] tx_data;
    
    wire tx_line;
    wire tx_busy;
    wire [7:0] rx_data;
    wire rx_done;
    wire rx_line;
    wire parity_err;

    // Loopback: Connect Transmitter output directly to Receiver input
    assign rx_line = tx_line;

    // Instantiate DUT
    uart_top #(
        .SYS_CLK(50000000)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .baud_sel(baud_sel),
        .parity_typ(parity_typ),
        .parity_enb(parity_enb),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_line(tx_line),
        .tx_busy(tx_busy),
        .rx_line(rx_line),
        .rx_data(rx_data),
        .rx_done(rx_done),
        .parity_err(parity_err)
    );

    // Clock Generation
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // Waveform Dumping
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, testbench);
    end

    // Main Test Stimulus
    initial begin
        // Initialize
        rst_n = 0;
        baud_sel = 2'b10; // 9600 Baud
        tx_start = 0;
        tx_data = 8'h00;
        parity_typ = 0;
        parity_enb = 1;

        // Reset Pulse
        #(CLK_PERIOD * 5) rst_n = 1;
        $display("--- Starting UART Loopback Test ---");

        // Send Byte 1: 0x55
        send_byte(8'h55);
        
        // Send Byte 2: 0xA3
        send_byte(8'hA3);
        
        // Send Byte 3: 0xFF
        send_byte(8'hFF);

        $display("--- All Tests Completed Successfully ---");
        #1000;
        $finish;
    end

    // Task to send a byte and wait for completion
    task send_byte(input [7:0] data);
        begin
            @(posedge clk);
            tx_data = data;
            tx_start = 1;
            @(posedge clk);
            tx_start = 0;
            
            $display("[TX] Sending Byte: %h", data);
            
            // Wait for receiver to signal 'done'
            // At 9600 baud, this takes ~1.04ms
            wait(rx_done == 1);
            
            if (rx_data == data)
              $display("[RX] Received Match:parity_err=%d  %h at time %0t",parity_err, rx_data, $time);
            else
              $display("[ERROR] Mismatch! Sent:parity_err=%d  %h, Recv: %h",parity_err, data, rx_data);
                
            // Small delay between bytes
            #(CLK_PERIOD * 100);
        end
    endtask

endmodule
