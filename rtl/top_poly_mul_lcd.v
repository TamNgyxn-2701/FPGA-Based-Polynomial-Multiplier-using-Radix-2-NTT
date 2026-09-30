// -----------------------------------------------------------------------------
// Top-level for Altera/Terasic DE2, Cyclone II EP2C35F672C6.
// KEY[0] : active-low reset
// KEY[1] : active-low start pulse
// SW[7:0]: select output coefficient C[index] for LCD display
// LCD    : shows selected coefficient and core status
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module top_poly_mul_lcd(
    input         CLOCK_50,
    input  [3:0]  KEY,
    input  [17:0] SW,
    output [17:0] LEDR,
    output [8:0]  LEDG,
    output [7:0]  LCD_DATA,
    output        LCD_EN,
    output        LCD_RS,
    output        LCD_RW,
    output        LCD_ON,
    output        LCD_BLON
);
    wire clk = CLOCK_50;
    wire rst_n = KEY[0];

    reg key1_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            key1_d <= 1'b1;
        end else begin
            key1_d <= KEY[1];
        end
    end
    wire start_pulse = key1_d & (~KEY[1]);

    wire [7:0] selected_idx = (SW[7:0] > 8'd254) ? 8'd254 : SW[7:0];
    wire [13:0] selected_value;
    wire core_busy;
    wire core_done;
    wire [3:0] core_state;

    poly_mul_ntt_core U_CORE (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_pulse),
        .busy(core_busy),
        .done(core_done),
        .state_dbg(core_state),
        .result_addr(selected_idx),
        .result_data(selected_value)
    );

    wire [127:0] lcd_line1;
    wire [127:0] lcd_line2;
    lcd_text_formatter U_FMT (
        .index(selected_idx),
        .value(selected_value),
        .busy(core_busy),
        .done(core_done),
        .line1(lcd_line1),
        .line2(lcd_line2)
    );

    lcd_16x2_driver U_LCD (
        .clk(clk),
        .rst_n(rst_n),
        .line1(lcd_line1),
        .line2(lcd_line2),
        .LCD_DATA(LCD_DATA),
        .LCD_EN(LCD_EN),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_ON(LCD_ON),
        .LCD_BLON(LCD_BLON)
    );

    assign LEDR[0]    = core_busy;
    assign LEDR[1]    = core_done;
    assign LEDR[5:2]  = core_state;
    assign LEDR[9:6]  = 4'b0000;
    assign LEDR[17:10]= selected_idx;

    assign LEDG[0] = ~rst_n;
    assign LEDG[1] = start_pulse;
    assign LEDG[8:2] = 7'b0000000;
endmodule
