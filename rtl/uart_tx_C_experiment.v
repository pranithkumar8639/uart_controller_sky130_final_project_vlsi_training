module uart_tx #(
    parameter CLKS_PER_BIT = 5208
)(
    input        clk,
    input        reset,
    input        tx_start,
    input  [7:0] tx_data,
    output reg   tx,
    output reg   tx_busy,
    output reg   tx_done
);
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state;
    reg [12:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  shreg;
    reg shift_en;
    reg pre;   // clk_count == CLKS_PER_BIT-2
    reg last;  // clk_count == CLKS_PER_BIT-1
    // LFSR baud counter: no carry chain
    localparam [12:0] SEED = 13'd1;
    function [12:0] lfsr_at;
        input integer n;
        integer i;
        reg [12:0] v;
        begin
            v = 13'd1;
            for (i = 0; i < n; i = i + 1)
                v = {v[11:0], v[12] ^ v[3] ^ v[2] ^ v[0]};
            lfsr_at = v;
        end
    endfunction
    localparam [12:0] PRE_TC = lfsr_at(CLKS_PER_BIT - 3);
    reg pre_lo, pre_hi;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE; clk_count <= SEED; bit_index <= 3'd0;
            shreg <= 8'd0; shift_en <= 1'b0; pre <= 1'b0; pre_lo <= 1'b0; pre_hi <= 1'b0; last <= 1'b0;
            tx <= 1'b1; tx_busy <= 1'b0; tx_done <= 1'b0;
        end
        else begin
            tx_done <= 1'b0;
            if (shift_en) shreg <= {1'b0, shreg[7:1]};
            shift_en <= (state == DATA) && pre && !last;
            case (state)
                IDLE: begin
                    tx <= 1'b1; tx_busy <= 1'b0;
                    clk_count <= SEED; bit_index <= 3'd0;
                    pre <= 1'b0; pre_lo <= 1'b0; pre_hi <= 1'b0; last <= 1'b0;
                    if (tx_start) begin
                        shreg <= tx_data; tx_busy <= 1'b1; state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    if (!last) begin
                        clk_count <= {clk_count[11:0], clk_count[12] ^ clk_count[3] ^ clk_count[2] ^ clk_count[0]};
                        pre  <= (clk_count == PRE_TC);
                        last <= pre;
                    end else begin
                        clk_count <= SEED; pre <= 1'b0; pre_lo <= 1'b0; pre_hi <= 1'b0; last <= 1'b0;
                        state <= DATA;
                    end
                end
                DATA: begin
                    tx <= shreg[0];
                    if (!last) begin
                        clk_count <= {clk_count[11:0], clk_count[12] ^ clk_count[3] ^ clk_count[2] ^ clk_count[0]};
                        pre  <= (clk_count == PRE_TC);
                        last <= pre;
                    end else begin
                        clk_count <= SEED; pre <= 1'b0; pre_lo <= 1'b0; pre_hi <= 1'b0; last <= 1'b0;
                        bit_index <= bit_index + 1'b1;
                        if (bit_index == 3'd7) state <= STOP;
                    end
                end
                STOP: begin
                    tx <= 1'b1;
                    if (!last) begin
                        clk_count <= {clk_count[11:0], clk_count[12] ^ clk_count[3] ^ clk_count[2] ^ clk_count[0]};
                        pre  <= (clk_count == PRE_TC);
                        last <= pre;
                    end else begin
                        clk_count <= SEED; pre <= 1'b0; pre_lo <= 1'b0; pre_hi <= 1'b0; last <= 1'b0;
                        tx_busy <= 1'b0; tx_done <= 1'b1; state <= IDLE;
                    end
                end
                default: begin
                    state <= IDLE; tx <= 1'b1; tx_busy <= 1'b0;
                    clk_count <= SEED; bit_index <= 3'd0;
                    pre <= 1'b0; pre_lo <= 1'b0; pre_hi <= 1'b0; last <= 1'b0;
                end
            endcase
        end
    end
endmodule
