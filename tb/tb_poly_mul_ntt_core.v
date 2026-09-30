`timescale 1ns/1ps

module tb_poly_mul_ntt_core;
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] result_addr;
    wire [13:0] result_data;
    wire busy;
    wire done;
    wire [3:0] state_dbg;

    reg [13:0] expected [0:254];
    integer i;
    integer errors;

    poly_mul_ntt_core DUT (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .busy(busy),
        .done(done),
        .state_dbg(state_dbg),
        .result_addr(result_addr),
        .result_data(result_data)
    );

    initial begin
        clk = 1'b0;
        forever #10 clk = ~clk; // 50 MHz
    end

    initial begin
        $readmemh("../tb/expected_c.mem", expected);
        rst_n = 1'b0;
        start = 1'b0;
        result_addr = 8'd0;
        errors = 0;

        repeat (10) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        wait(done == 1'b1);
        @(posedge clk);

        for (i = 0; i < 255; i = i + 1) begin
            result_addr = i[7:0];
            #1;
            if (result_data !== expected[i]) begin
                $display("MISMATCH C[%0d]: got %0d expected %0d", i, result_data, expected[i]);
                errors = errors + 1;
            end
        end

        if (errors == 0) begin
            $display("PASS: all 255 coefficients match golden model.");
        end else begin
            $display("FAIL: %0d mismatches.", errors);
        end
        $stop;
    end
endmodule
