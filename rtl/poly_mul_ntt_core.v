// -----------------------------------------------------------------------------
// Polynomial multiplier core:
//   - Multiplies two degree-127 polynomials modulo q=12289.
//   - Uses zero-padding to N=256.
//   - Uses forward DIF NTT, pointwise Montgomery multiplication, inverse DIT NTT.
//   - Returns C[0..254] in normal integer representation, modulo q.
//
// The demonstration coefficients are stored in input_rom_128.v. Replace that ROM
// or add a bus/CPU loader if dynamic inputs are required.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module poly_mul_ntt_core(
    input         clk,
    input         rst_n,
    input         start,
    output reg    busy,
    output reg    done,
    output [3:0]  state_dbg,

    input  [7:0]  result_addr,
    output [13:0] result_data
);
    localparam [13:0] R2_MOD_Q = 14'd10952; // R^2 mod q, R=2^16
    localparam [13:0] ONE      = 14'd1;

    localparam S_IDLE       = 4'd0;
    localparam S_LOAD       = 4'd1;
    localparam S_START_NTT  = 4'd2;
    localparam S_WAIT_NTT   = 4'd3;
    localparam S_POINTWISE  = 4'd4;
    localparam S_START_INTT = 4'd5;
    localparam S_WAIT_INTT  = 4'd6;
    localparam S_FROM_MONT  = 4'd7;
    localparam S_DONE       = 4'd8;

    reg [3:0] state;
    assign state_dbg = state;

    reg [7:0] cnt;
    reg [13:0] result_mem [0:254];
    assign result_data = (result_addr < 8'd255) ? result_mem[result_addr] : 14'd0;

    wire [6:0] rom_addr = cnt[6:0];
    wire [13:0] a_coeff;
    wire [13:0] b_coeff;
    input_rom_128 U_INPUT_ROM (
        .addr(rom_addr),
        .a_coeff(a_coeff),
        .b_coeff(b_coeff)
    );

    wire [13:0] a_raw = (cnt < 8'd128) ? a_coeff : 14'd0;
    wire [13:0] b_raw = (cnt < 8'd128) ? b_coeff : 14'd0;
    wire [13:0] a_mont;
    wire [13:0] b_mont;

    montgomery_mul_q12289 U_TO_MONT_A (.a(a_raw), .b(R2_MOD_Q), .y(a_mont));
    montgomery_mul_q12289 U_TO_MONT_B (.a(b_raw), .b(R2_MOD_Q), .y(b_mont));

    reg start_a;
    reg start_b;
    reg start_c;

    wire busy_a, busy_b, busy_c;
    wire done_a, done_b, done_c;

    wire [7:0] rd_addr_a = (state == S_POINTWISE) ? cnt : 8'd0;
    wire [7:0] rd_addr_b = (state == S_POINTWISE) ? cnt : 8'd0;
    wire [7:0] rd_addr_c = (state == S_FROM_MONT) ? cnt : 8'd0;

    wire [13:0] ntt_a_data;
    wire [13:0] ntt_b_data;
    wire [13:0] ntt_c_data;

    wire load_ab = (state == S_LOAD);
    wire load_c  = (state == S_POINTWISE);

    wire [13:0] pointwise_product;
    montgomery_mul_q12289 U_POINTWISE_MUL (
        .a(ntt_a_data),
        .b(ntt_b_data),
        .y(pointwise_product)
    );

    wire [13:0] normal_result;
    montgomery_mul_q12289 U_FROM_MONT (
        .a(ntt_c_data),
        .b(ONE),
        .y(normal_result)
    );

    ntt_core_256 U_NTT_A (
        .clk(clk), .rst_n(rst_n), .start(start_a), .inverse(1'b0),
        .busy(busy_a), .done(done_a),
        .load_we(load_ab), .load_addr(cnt), .load_data(a_mont),
        .rd_addr(rd_addr_a), .rd_data(ntt_a_data)
    );

    ntt_core_256 U_NTT_B (
        .clk(clk), .rst_n(rst_n), .start(start_b), .inverse(1'b0),
        .busy(busy_b), .done(done_b),
        .load_we(load_ab), .load_addr(cnt), .load_data(b_mont),
        .rd_addr(rd_addr_b), .rd_data(ntt_b_data)
    );

    ntt_core_256 U_NTT_C (
        .clk(clk), .rst_n(rst_n), .start(start_c), .inverse(1'b1),
        .busy(busy_c), .done(done_c),
        .load_we(load_c), .load_addr(cnt), .load_data(pointwise_product),
        .rd_addr(rd_addr_c), .rd_data(ntt_c_data)
    );

    integer i;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state   <= S_IDLE;
            cnt     <= 8'd0;
            busy    <= 1'b0;
            done    <= 1'b0;
            start_a <= 1'b0;
            start_b <= 1'b0;
            start_c <= 1'b0;
            for (i = 0; i < 255; i = i + 1) begin
                result_mem[i] <= 14'd0;
            end
        end else begin
            start_a <= 1'b0;
            start_b <= 1'b0;
            start_c <= 1'b0;

            case (state)
                S_IDLE: begin
                    busy <= 1'b0;
                    done <= 1'b0;
                    cnt  <= 8'd0;
                    if (start) begin
                        busy <= 1'b1;
                        state <= S_LOAD;
                    end
                end

                S_LOAD: begin
                    busy <= 1'b1;
                    done <= 1'b0;
                    if (cnt == 8'd255) begin
                        cnt <= 8'd0;
                        state <= S_START_NTT;
                    end else begin
                        cnt <= cnt + 8'd1;
                    end
                end

                S_START_NTT: begin
                    start_a <= 1'b1;
                    start_b <= 1'b1;
                    state <= S_WAIT_NTT;
                end

                S_WAIT_NTT: begin
                    if (done_a && done_b) begin
                        cnt <= 8'd0;
                        state <= S_POINTWISE;
                    end
                end

                S_POINTWISE: begin
                    if (cnt == 8'd255) begin
                        cnt <= 8'd0;
                        state <= S_START_INTT;
                    end else begin
                        cnt <= cnt + 8'd1;
                    end
                end

                S_START_INTT: begin
                    start_c <= 1'b1;
                    state <= S_WAIT_INTT;
                end

                S_WAIT_INTT: begin
                    if (done_c) begin
                        cnt <= 8'd0;
                        state <= S_FROM_MONT;
                    end
                end

                S_FROM_MONT: begin
                    result_mem[cnt] <= normal_result;
                    if (cnt == 8'd254) begin
                        state <= S_DONE;
                    end else begin
                        cnt <= cnt + 8'd1;
                    end
                end

                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    if (start) begin
                        cnt <= 8'd0;
                        busy <= 1'b1;
                        done <= 1'b0;
                        state <= S_LOAD;
                    end
                end

                default: begin
                    state <= S_IDLE;
                end
            endcase
        end
    end
endmodule
