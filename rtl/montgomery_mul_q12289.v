// -----------------------------------------------------------------------------
// Montgomery multiplication modulo q = 12289, R = 2^16.
// Computes y = a * b * R^-1 mod q.
// Parameters:
//   q    = 12289
//   R    = 65536
//   qinv = -q^(-1) mod R = 12287
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module montgomery_mul_q12289(
    input  [13:0] a,
    input  [13:0] b,
    output [13:0] y
);
    localparam [31:0] Q    = 32'd12289;
    localparam [15:0] QINV = 16'd12287;

    wire [31:0] t = a * b;
    wire [15:0] m = t[15:0] * QINV;
    wire [31:0] u_full = (t + ({16'd0, m} * Q)) >> 16;

    wire [31:0] u_sub1 = u_full - Q;
    wire [31:0] u_red1 = (u_full >= Q) ? u_sub1 : u_full;
    wire [31:0] u_sub2 = u_red1 - Q;
    wire [31:0] u_red2 = (u_red1 >= Q) ? u_sub2 : u_red1;

    assign y = u_red2[13:0];
endmodule
