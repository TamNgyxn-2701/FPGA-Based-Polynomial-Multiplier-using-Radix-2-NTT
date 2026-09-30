// -----------------------------------------------------------------------------
// Formats result index/value into two 16-character LCD lines.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module lcd_text_formatter(
    input  [7:0]  index,
    input  [13:0] value,
    input         busy,
    input         done,
    output reg [127:0] line1,
    output reg [127:0] line2
);
    reg [7:0] idx_h, idx_t, idx_o;
    reg [7:0] v_10000, v_1000, v_100, v_10, v_1;
    reg [7:0] s0, s1, s2, s3;

    integer temp_i;
    integer temp_v;

    always @(*) begin
        temp_i = index;
        idx_h = (temp_i / 100) + 8'd48;
        temp_i = temp_i % 100;
        idx_t = (temp_i / 10) + 8'd48;
        idx_o = (temp_i % 10) + 8'd48;

        temp_v = value;
        v_10000 = (temp_v / 10000) + 8'd48;
        temp_v = temp_v % 10000;
        v_1000  = (temp_v / 1000) + 8'd48;
        temp_v = temp_v % 1000;
        v_100   = (temp_v / 100) + 8'd48;
        temp_v = temp_v % 100;
        v_10    = (temp_v / 10) + 8'd48;
        v_1     = (temp_v % 10) + 8'd48;

        if (busy) begin
            s0 = "B"; s1 = "U"; s2 = "S"; s3 = "Y";
        end else if (done) begin
            s0 = "D"; s1 = "O"; s2 = "N"; s3 = "E";
        end else begin
            s0 = "I"; s1 = "D"; s2 = "L"; s3 = "E";
        end

        // 16 chars: "NTT C[xxx]      "
        line1 = {"N","T","T"," ","C","[",idx_h,idx_t,idx_o,"]"," "," "," "," "," "," "};
        // 16 chars: "VAL=xxxxx STAT  "
        line2 = {"V","A","L","=",v_10000,v_1000,v_100,v_10,v_1," ",s0,s1,s2,s3," "," "};
    end
endmodule
