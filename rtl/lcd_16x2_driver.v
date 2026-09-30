// -----------------------------------------------------------------------------
// Simple HD44780 16x2 LCD text driver for the DE2 board.
// Writes 8-bit data bus, no busy-flag read. Timing assumes clk=50MHz.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module lcd_16x2_driver(
    input         clk,
    input         rst_n,
    input  [127:0] line1,
    input  [127:0] line2,
    output reg [7:0] LCD_DATA,
    output reg       LCD_EN,
    output reg       LCD_RS,
    output           LCD_RW,
    output           LCD_ON,
    output           LCD_BLON
);
    assign LCD_RW   = 1'b0;
    assign LCD_ON   = 1'b1;
    assign LCD_BLON = 1'b1;

    localparam INIT_WAIT = 20'd750000; // 15 ms at 50 MHz
    localparam OP_WAIT   = 17'd100000; // 2 ms at 50 MHz, safe for clear/home too
    localparam PULSE_W   = 8'd50;      // 1 us enable pulse

    localparam ST_INIT_WAIT = 3'd0;
    localparam ST_SETUP     = 3'd1;
    localparam ST_EN_HIGH   = 3'd2;
    localparam ST_EN_LOW    = 3'd3;
    localparam ST_WAIT      = 3'd4;

    reg [2:0] state;
    reg [19:0] wait_cnt;
    reg [7:0] pulse_cnt;
    reg [5:0] seq;
    reg [7:0] curr_byte;
    reg curr_rs;

    function [7:0] char_at;
        input [127:0] line;
        input [4:0] pos;
        begin
            case (pos)
                5'd0:  char_at = line[127:120];
                5'd1:  char_at = line[119:112];
                5'd2:  char_at = line[111:104];
                5'd3:  char_at = line[103:96];
                5'd4:  char_at = line[95:88];
                5'd5:  char_at = line[87:80];
                5'd6:  char_at = line[79:72];
                5'd7:  char_at = line[71:64];
                5'd8:  char_at = line[63:56];
                5'd9:  char_at = line[55:48];
                5'd10: char_at = line[47:40];
                5'd11: char_at = line[39:32];
                5'd12: char_at = line[31:24];
                5'd13: char_at = line[23:16];
                5'd14: char_at = line[15:8];
                5'd15: char_at = line[7:0];
                default: char_at = 8'h20;
            endcase
        end
    endfunction

    always @(*) begin
        curr_rs = 1'b0;
        curr_byte = 8'h20;
        if (seq == 6'd0) begin
            curr_byte = 8'h38; // 8-bit, 2-line, 5x8 font
            curr_rs = 1'b0;
        end else if (seq == 6'd1) begin
            curr_byte = 8'h0C; // display on, cursor off
            curr_rs = 1'b0;
        end else if (seq == 6'd2) begin
            curr_byte = 8'h01; // clear display
            curr_rs = 1'b0;
        end else if (seq == 6'd3) begin
            curr_byte = 8'h06; // entry mode increment
            curr_rs = 1'b0;
        end else if (seq == 6'd4) begin
            curr_byte = 8'h80; // line 1 DDRAM address
            curr_rs = 1'b0;
        end else if ((seq >= 6'd5) && (seq <= 6'd20)) begin
            curr_byte = char_at(line1, seq - 6'd5);
            curr_rs = 1'b1;
        end else if (seq == 6'd21) begin
            curr_byte = 8'hC0; // line 2 DDRAM address
            curr_rs = 1'b0;
        end else if ((seq >= 6'd22) && (seq <= 6'd37)) begin
            curr_byte = char_at(line2, seq - 6'd22);
            curr_rs = 1'b1;
        end else begin
            curr_byte = 8'h80;
            curr_rs = 1'b0;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_INIT_WAIT;
            wait_cnt <= 20'd0;
            pulse_cnt <= 8'd0;
            seq <= 6'd0;
            LCD_DATA <= 8'h00;
            LCD_RS <= 1'b0;
            LCD_EN <= 1'b0;
        end else begin
            case (state)
                ST_INIT_WAIT: begin
                    LCD_EN <= 1'b0;
                    if (wait_cnt >= INIT_WAIT) begin
                        wait_cnt <= 20'd0;
                        seq <= 6'd0;
                        state <= ST_SETUP;
                    end else begin
                        wait_cnt <= wait_cnt + 20'd1;
                    end
                end

                ST_SETUP: begin
                    LCD_DATA <= curr_byte;
                    LCD_RS <= curr_rs;
                    LCD_EN <= 1'b0;
                    pulse_cnt <= 8'd0;
                    state <= ST_EN_HIGH;
                end

                ST_EN_HIGH: begin
                    LCD_EN <= 1'b1;
                    if (pulse_cnt >= PULSE_W) begin
                        pulse_cnt <= 8'd0;
                        state <= ST_EN_LOW;
                    end else begin
                        pulse_cnt <= pulse_cnt + 8'd1;
                    end
                end

                ST_EN_LOW: begin
                    LCD_EN <= 1'b0;
                    wait_cnt <= 20'd0;
                    state <= ST_WAIT;
                end

                ST_WAIT: begin
                    if (wait_cnt >= OP_WAIT) begin
                        wait_cnt <= 20'd0;
                        if (seq >= 6'd37) begin
                            seq <= 6'd4; // refresh text only; do not clear every loop
                        end else begin
                            seq <= seq + 6'd1;
                        end
                        state <= ST_SETUP;
                    end else begin
                        wait_cnt <= wait_cnt + 20'd1;
                    end
                end

                default: state <= ST_INIT_WAIT;
            endcase
        end
    end
endmodule
