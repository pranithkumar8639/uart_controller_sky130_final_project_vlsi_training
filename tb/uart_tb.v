`timescale 1ns/1ps
module uart_tb;

    // ------------------------------------------------
    // Simulation parameters
    // ------------------------------------------------
    parameter CLKS_PER_BIT = 5208;

    // ------------------------------------------------
    // Clock and reset
    // ------------------------------------------------
    reg clk;
    reg reset;

    // ------------------------------------------------
    // TX interface
    // ------------------------------------------------
    reg        tx_start;
    reg [7:0]  tx_data;

    wire       tx;
    wire       tx_busy;
    wire       tx_done;

    // ------------------------------------------------
    // RX interface
    // ------------------------------------------------
    wire       rx;
    wire [7:0] rx_data;
    wire       rx_valid;

    // ------------------------------------------------
    // LOOPBACK CONNECTION
    // TX output is directly connected to RX input
    // ------------------------------------------------
    assign rx = tx;

    // ------------------------------------------------
    // UART TOP MODULE
    // ------------------------------------------------
    uart_top dut (
        .clk      (clk),
        .reset    (reset),

        .tx_start (tx_start),
        .tx_data  (tx_data),

        .tx       (tx),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done),

        .rx       (rx),
        .rx_data  (rx_data),
        .rx_valid (rx_valid)
    );

    // ------------------------------------------------
    // CLOCK
    // 10 ns clock period
    // ------------------------------------------------
    initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
    end

    // ------------------------------------------------
    // VCD DUMP
    // ------------------------------------------------
    initial begin
        $dumpfile("uart.vcd");
        $dumpvars(0, uart_tb);
    end

    // ------------------------------------------------
    // MAIN TEST
    // ------------------------------------------------
    initial begin

        reset    = 1'b1;
        tx_start = 1'b0;
        tx_data  = 8'h00;

        // Reset
        #100;

        reset = 1'b0;

        // --------------------------------------------
        // TEST 1
        // --------------------------------------------
        $display("");
        $display("========================================");
        $display("TEST 1: Transmitting 0x55");
        $display("========================================");

        @(negedge clk);

	tx_data  = 8'h55;
	tx_start = 1'b1;

	$display("TX START asserted");
	$display("TX DATA = 0x%02h", tx_data);

	@(negedge clk);

	tx_start = 1'b0;
        // Wait for transmission to complete
        // Wait for receiver
                // Wait for both TX completion and RX reception
        fork
            begin
                wait (tx_done == 1'b1);
                $display("TX DONE detected");
                $display("Transmission completed");
            end

            begin
                wait (rx_valid == 1'b1);
                $display("RX VALID detected");
                $display("RX DATA = 0x%02h", rx_data);
            end
        join
        // Check received data
        if (rx_data == 8'h55) begin

            $display("");
            $display("========================================");
            $display("TEST 1 PASSED");
            $display("TX DATA = 0x55");
            $display("RX DATA = 0x55");
            $display("========================================");

        end
        else begin

            $display("");
            $display("========================================");
            $display("TEST 1 FAILED");
            $display("Expected RX = 0x55");
            $display("Actual RX   = 0x%02h", rx_data);
            $display("========================================");

        end
          #100;

$display("");
$display("TEST 2 START TIME = %0t", $time);
$display("========================================");
$display("TEST 2: Transmitting 0xA5");
$display("========================================");
@(negedge clk);

tx_data  = 8'hA5;
tx_start = 1'b1;

$display("TX START asserted");
$display("TX DATA = 0x%02h", tx_data);

@(negedge clk);

tx_start = 1'b0;

// Wait for both TX and RX to complete
fork
    begin
        wait (tx_done == 1'b1);
        $display(">>> TEST 2: TX DONE detected");
    end

    begin
        wait (rx_valid == 1'b1);
        $display(">>> TEST 2: RX VALID detected");
        $display(">>> TEST 2: RX DATA = 0x%02h", rx_data);
    end
join

$display(">>> TEST 2: BOTH TX AND RX COMPLETED");

if (rx_data == 8'hA5) begin

    $display("");
    $display("========================================");
    $display("TEST 2 PASSED");
    $display("TX DATA = 0xA5");
    $display("RX DATA = 0xA5");
    $display("========================================");

end
else begin

    $display("");
    $display("========================================");
    $display("TEST 2 FAILED");
    $display("Expected RX = 0xA5");
    $display("Actual RX   = 0x%02h", rx_data);
    $display("========================================");

end

#100;

// --------------------------------------------
// SIMULATION COMPLETE
// --------------------------------------------

$display("");
$display("========================================");
$display("ALL TESTS COMPLETED");
$display("========================================");

$finish;

end

// ------------------------------------------------
// SAFETY TIMEOUT
// ------------------------------------------------
initial begin

    #2000000;

    $display("");
    $display("========================================");
    $display("ERROR: SIMULATION TIMEOUT");
    $display("========================================");

    $finish;


end


endmodule

