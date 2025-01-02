`default_nettype none
`include "pwm.v"
module top(output [2:0] RGB, input clk, enable, data, output data_out);

    wire internal_clk;
    wire pwm_enable_r;
    wire pwm_enable_g;
    wire pwm_enable_b;

    reg [0:7] registers [0:7];
    reg [0:7] addr_in;
    reg [0:15] data_in;

    reg [0:3] index;
    reg data_set;
    wire [0:6] pwm_val_r;
    wire [0:6] pwm_val_g;
    wire [0:6] pwm_val_b;

    reg pwm_out_r;
    reg pwm_out_g;
    reg pwm_out_b;

    assign RGB[0] = ((registers[0] & 8'h01) == 8'h01) ? ((pwm_enable_r) ?  ~pwm_out_r : registers[1] & 8'h01) : 1;
    assign RGB[1] = ((registers[2] & 8'h01) == 8'h01) ? ((pwm_enable_g) ?  ~pwm_out_g : registers[3] & 8'h01) : 1;
    assign RGB[2] = ((registers[4] & 8'h01) == 8'h01) ? ((pwm_enable_b) ?  ~pwm_out_b : registers[5] & 8'h01) : 1;

    assign pwm_enable_r = ((registers[0] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_enable_g = ((registers[2] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_enable_b = ((registers[4] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_val_r =| (pwm_enable_r) ? ((registers[0] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.
    assign pwm_val_g =| (pwm_enable_g) ? ((registers[2] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.
    assign pwm_val_b =| (pwm_enable_b) ? ((registers[4] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.

    initial begin
        index = 0;
        data_in = 0;
        addr_in = 0;
        data_set = 0;
    end

    SB_HFOSC SB_HFOSC_inst(
    .CLKHFEN(1),
    .CLKHFPU(1),
    .CLKHF(internal_clk)
    );

    pwm pwm_init_r(.clk(internal_clk), .en(pwm_enable_r),.value_input(pwm_val_r),.out(pwm_out_r));
    pwm pwm_init_g(.clk(internal_clk), .en(pwm_enable_g),.value_input(pwm_val_g),.out(pwm_out_g));
    pwm pwm_init_b(.clk(internal_clk), .en(pwm_enable_b),.value_input(pwm_val_b),.out(pwm_out_b));

    always @(posedge clk) begin

        if (enable) begin
            if (data_set) begin data_set <= 0; end
            data_in[index] <= data;
            index <= index + 1;
        end 
    end

    always @(posedge internal_clk) begin 
        if ((0 == enable) && (0 == data_set)) begin
            registers[data_in[0:7]] <= data_in[8:15];
            data_set <= 1;
        end
    end

endmodule