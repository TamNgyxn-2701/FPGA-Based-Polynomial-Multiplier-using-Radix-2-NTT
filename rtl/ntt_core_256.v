// -----------------------------------------------------------------------------
// Sequential radix-2 NTT core, length 256, q=12289, Montgomery domain.
//
// Forward mode (inverse=0): DIF NTT, natural-order input -> bit-reversed output.
// Inverse mode (inverse=1): DIT inverse NTT, bit-reversed input -> natural output,
// then scales by N^-1. This pairing avoids an explicit bit-reversal block.
//
// Memory interface:
//   load_we/load_addr/load_data: write coefficient when core is not busy.
//   rd_addr/rd_data: asynchronous read for top/testbench.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module ntt_core_256(
    input         clk,
    input         rst_n,
    input         start,
    input         inverse,
    output reg    busy,
    output reg    done,

    input         load_we,
    input  [7:0]  load_addr,
    input  [13:0] load_data,

    input  [7:0]  rd_addr,
    output [13:0] rd_data
);
    localparam [13:0] NINV_MONT = 14'd256; // (256^-1 mod 12289) * R mod q

    localparam S_IDLE  = 2'd0;
    localparam S_BF    = 2'd1;
    localparam S_SCALE = 2'd2;
    localparam S_DONE  = 2'd3;

    reg [1:0] state;
    reg inv_reg;
    reg [3:0] stage;
    reg [8:0] block;
    reg [7:0] j;
    reg [7:0] scale_idx;

    reg [13:0] mem [0:255];

    assign rd_data = mem[rd_addr];

    wire [8:0] len  = inv_reg ? (9'd2   << stage) : (9'd256 >> stage);
    wire [7:0] half = inv_reg ? (8'd1   << stage) : (8'd128 >> stage);
    wire [7:0] step = inv_reg ? (8'd128 >> stage) : (8'd1   << stage);

    wire [8:0] idx1_w = block + {1'b0, j};
    wire [8:0] idx2_w = block + {1'b0, j} + {1'b0, half};
    wire [7:0] idx1 = idx1_w[7:0];
    wire [7:0] idx2 = idx2_w[7:0];

    wire [15:0] tw_temp = j * step;
    wire [7:0] tw_addr = tw_temp[7:0];
    wire [13:0] twiddle;

    twiddle_rom_256 U_TWIDDLE (
        .inv(inv_reg),
        .addr(tw_addr),
        .twiddle(twiddle)
    );

    wire [13:0] u = mem[idx1];
    wire [13:0] v = mem[idx2];

    wire [13:0] fwd_add;
    wire [13:0] fwd_sub;
    wire [13:0] fwd_mul;
    wire [13:0] inv_vtw;
    wire [13:0] inv_add;
    wire [13:0] inv_sub;

    mod_add_q12289 U_FWD_ADD (.a(u), .b(v),       .y(fwd_add));
    mod_sub_q12289 U_FWD_SUB (.a(u), .b(v),       .y(fwd_sub));
    montgomery_mul_q12289 U_FWD_MUL (.a(fwd_sub), .b(twiddle), .y(fwd_mul));

    montgomery_mul_q12289 U_INV_MUL (.a(v),       .b(twiddle), .y(inv_vtw));
    mod_add_q12289 U_INV_ADD (.a(u), .b(inv_vtw), .y(inv_add));
    mod_sub_q12289 U_INV_SUB (.a(u), .b(inv_vtw), .y(inv_sub));

    wire [13:0] scaled_value;
    montgomery_mul_q12289 U_SCALE_MUL (
        .a(mem[scale_idx]),
        .b(NINV_MONT),
        .y(scaled_value)
    );

    integer k;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= S_IDLE;
            busy      <= 1'b0;
            done      <= 1'b0;
            inv_reg   <= 1'b0;
            stage     <= 4'd0;
            block     <= 9'd0;
            j         <= 8'd0;
            scale_idx <= 8'd0;
            for (k = 0; k < 256; k = k + 1) begin
                mem[k] <= 14'd0;
            end
        end else begin
            done <= 1'b0;

            if (!busy && load_we) begin
                mem[load_addr] <= load_data;
            end

            case (state)
                S_IDLE: begin
                    busy <= 1'b0;
                    if (start) begin
                        inv_reg   <= inverse;
                        stage     <= 4'd0;
                        block     <= 9'd0;
                        j         <= 8'd0;
                        scale_idx <= 8'd0;
                        busy      <= 1'b1;
                        state     <= S_BF;
                    end
                end

                S_BF: begin
                    busy <= 1'b1;
                    if (!inv_reg) begin
                        // Forward DIF butterfly
                        mem[idx1] <= fwd_add;
                        mem[idx2] <= fwd_mul;
                    end else begin
                        // Inverse DIT butterfly
                        mem[idx1] <= inv_add;
                        mem[idx2] <= inv_sub;
                    end

                    if (j == (half - 8'd1)) begin
                        j <= 8'd0;
                        if ((block + len) >= 9'd256) begin
                            block <= 9'd0;
                            if (stage == 4'd7) begin
                                if (inv_reg) begin
                                    scale_idx <= 8'd0;
                                    state <= S_SCALE;
                                end else begin
                                    state <= S_DONE;
                                end
                            end else begin
                                stage <= stage + 4'd1;
                            end
                        end else begin
                            block <= block + len;
                        end
                    end else begin
                        j <= j + 8'd1;
                    end
                end

                S_SCALE: begin
                    busy <= 1'b1;
                    mem[scale_idx] <= scaled_value;
                    if (scale_idx == 8'd255) begin
                        state <= S_DONE;
                    end else begin
                        scale_idx <= scale_idx + 8'd1;
                    end
                end

                S_DONE: begin
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                    busy <= 1'b0;
                end
            endcase
        end
    end
endmodule
