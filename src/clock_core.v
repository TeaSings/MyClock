module clock_core (
    input clk,
    input clr,
    input tick,

    input [2:0] mode_sel,

    input ui_select,
    input ui_inc,
    input ui_dec,
    input ui_confirm,
    input ui_start,
    input ui_pause,
    input ui_stop,

    input alarm_enable_sw,

    input set_en,
    input [3:0] set_low,
    input [3:0] set_high,

    output [6:0] seg_sec_low,
    output [3:0] bcd_sec_high,
    output [3:0] bcd_min_low,
    output [3:0] bcd_min_high,
    output [3:0] bcd_hour_low,
    output [3:0] bcd_hour_high,
    output ring
);

    time_core u_time_core(
        .clk(clk),
        .clr(clr),
        .tick(tick),
        .set_en(set_en),
        .set_low(set_low),
        .set_high(set_high),
        .seg_sec_low(seg_sec_low),
        .bcd_sec_high(bcd_sec_high),
        .bcd_min_low(bcd_min_low),
        .bcd_min_high(bcd_min_high),
        .bcd_hour_low(bcd_hour_low),
        .bcd_hour_high(bcd_hour_high)
    );

endmodule
