module generic_counter #(
    parameter MAX_HIGH = 5,
    parameter MAX_LOW = 9
) (
    input clr,
    input clk,
    input tick,
    input set_en,
    input [3:0] set_low,
    input [3:0] set_high,
    output reg [3:0] output_high,
    output reg [3:0] output_low,
    output reg cout
);

    always @(posedge clk or negedge clr) begin
        if (!clr) begin
            output_low <= 4'd0;
            output_high <= 4'd0;
            cout <= 1'b0;
        end
        else begin
            cout <= 1'b0;

            if (set_en) begin
                output_low <= set_low;
                output_high <= set_high;
            end else if (tick) begin
                if (output_low == MAX_LOW[3:0]) begin
                    output_low <= 4'd0;
                    if (output_high == MAX_HIGH[3:0]) begin
                        output_high <= 4'd0;
                        cout <= 1'b1;
                    end else begin
                        output_high <= output_high + 1'b1;
                    end
                end else begin
                    output_low <= output_low + 1'b1;
                end
            end
        end
    end
endmodule