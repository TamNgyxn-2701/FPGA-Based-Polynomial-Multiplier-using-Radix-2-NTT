// -----------------------------------------------------------------------------
// Modular arithmetic helper blocks for q = 12289.
// All operands are canonical residues in [0, q-1].
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module mod_add_q12289(
    input  [13:0] a,
    input  [13:0] b,
    output [13:0] y
);
    localparam [14:0] Q = 15'd12289;
    wire [14:0] s = {1'b0,a} + {1'b0,b};
    wire [14:0] s_minus_q = s - Q;
    assign y = (s >= Q) ? s_minus_q[13:0] : s[13:0];
endmodule

module mod_sub_q12289(
    input  [13:0] a,
    input  [13:0] b,
    output [13:0] y
);
    localparam [14:0] Q = 15'd12289;
    wire [14:0] aa = {1'b0,a};
    wire [14:0] bb = {1'b0,b};
    wire [14:0] diff1 = aa - bb;
    wire [14:0] diff2 = aa + Q - bb;
    assign y = (aa >= bb) ? diff1[13:0] : diff2[13:0];
endmodule
