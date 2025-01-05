`default_nettype none
`include "pwm.v"
`include "bidir.v"
module top(output [2:0] RGB, input clk, enable, data, output data_out, inout P13, inout P20);

    wire internal_clk;
    wire [0:5] pwm_enable;
    // wire pwm_enable_g;
    // wire pwm_enable_b;
    // wire pwm_enable_13;
    // wire pwm_enable_20;
    wire [0:2] inp;
    wire [0:2] outp;
    wire [0:2] bidir;
    wire [0:2] oe;

    reg [0:7] registers [0:15];
    reg [0:7] addr_in;
    reg [0:3] addr_index;
    reg [0:32] data_in;
    reg [0:7] t_data_out;

    reg [0:4] index;
    reg [0:2] read_index;
    reg data_set;
    reg is_read;
    reg read_addr_set;
    wire [0:6] pwm_val [0:5];
    // wire [0:6] pwm_val_g;
    // wire [0:6] pwm_val_b;
    // wire [0:6] pwm_val_13;
    // wire [0:6] pwm_val_13;

    reg [0:5] pwm_out;
    // reg pwm_out_g;
    // reg pwm_out_b;
    // reg pwm_out_13;
    // reg pwm_out_13;
    reg [0:2] oe_i;
    reg bit_read;
    wire [0:2] b;

    assign RGB[0] = ((registers[0] & 8'h01) == 8'h01) ? ((pwm_enable[0]) ?  ~pwm_out[0] : registers[1] & 8'h01) : 1; // blue
    assign RGB[1] = ((registers[2] & 8'h01) == 8'h01) ? ((pwm_enable[1]) ?  ~pwm_out[1] : registers[3] & 8'h01) : 1; // green
    assign RGB[2] = ((registers[4] & 8'h01) == 8'h01) ? ((pwm_enable[2]) ?  ~pwm_out[2] : registers[5] & 8'h01) : 1; // red

    assign pwm_enable[0] = ((registers[0] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_enable[1] = ((registers[2] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_enable[2] = ((registers[4] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_enable[3] = ((registers[6] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_enable[5] = ((registers[8] & 8'h80) == 8'h80) ? 1 : 0;
    assign pwm_val[0] =| (pwm_enable[0]) ? ((registers[0] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.
    assign pwm_val[1] =| (pwm_enable[1]) ? ((registers[2] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.
    assign pwm_val[2] =| (pwm_enable[2]) ? ((registers[4] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.
    assign pwm_val[3] =| (pwm_enable[3]) ? ((registers[6] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.
    assign pwm_val[5] =| (pwm_enable[5]) ? ((registers[8] & 8'h7E) >> 1) : 0; // mask over the middle 6 bit, shift to the right.

    assign P13 = oe[0] ? b[0] : 'bZ;
    assign bidir[0] = oe[0] ? inp[0] : P13;
    assign P20 = oe[1] ? b[1] : 'bZ;
    assign bidir[1] = oe[1] ? inp[1] : P20;

    assign inp[0] = ((registers[6] & 8'h01) == 8'h01) ? ((pwm_enable[3]) ?  ~pwm_out[3] : registers[7] & 8'h01) : 1;
    assign inp[1] = ((registers[8] & 8'h01) == 8'h01) ? ((pwm_enable[5]) ?  ~pwm_out[5] : registers[9] & 8'h01) : 1;
    assign oe[0] = oe_i[0];
    assign oe[1] = oe_i[1];

    assign data_out = bit_read;

    integer i;
    initial begin
        index = 0;
        read_index = 0;
        data_in = 0;
        addr_in = 0;
        data_set = 0;
        read_addr_set = 0;
        for (i = 0; i < 256; i = i + 1) begin 
            registers[i] = 8'h00;
        end
    end

    SB_HFOSC SB_HFOSC_inst(
    .CLKHFEN(1),
    .CLKHFPU(1),
    .CLKHF(internal_clk)
    );

    pwm pwm_init_b(.clk(internal_clk), .en(pwm_enable[0]),.value_input(pwm_val[0]),.out(pwm_out[0]));
    pwm pwm_init_g(.clk(internal_clk), .en(pwm_enable[1]),.value_input(pwm_val[1]),.out(pwm_out[1]));
    pwm pwm_init_r(.clk(internal_clk), .en(pwm_enable[2]),.value_input(pwm_val[2]),.out(pwm_out[2]));
    pwm pwm_init_13(.clk(internal_clk), .en(pwm_enable[3]),.value_input(pwm_val[3]),.out(pwm_out[3]));
    pwm pwm_init_20(.clk(internal_clk), .en(pwm_enable[5]),.value_input(pwm_val[5]),.out(pwm_out[5]));

    bidir bidir_init_13(.oe(oe[0]), .clk(internal_clk), .inp(inp[0]), .outp(b[0]), .bidir(bidir[0]));
    bidir bidir_init_20(.oe(oe[1]), .clk(internal_clk), .inp(inp[1]), .outp(b[1]), .bidir(bidir[1]));

    always @(posedge clk) begin

        if (enable) begin
            if (data_set) begin data_set <= 0; end
            if (8 > index) begin
                data_in[index] <= data;
            end
            if ((8 <= index) && is_read) begin
                if (0 == read_index) begin
                    read_addr_set <= 0;
                end
                bit_read <= registers[addr_in][read_index];
                read_index <= read_index + 1;
            end
            if ((8 <= index) && (0 == is_read)) begin
                data_in[index] <= data;
            end
            if (23 == index) begin
                index <= 0;
            end
            else if (0 == is_read) begin
                index <= index + 1;
            end
            else if (is_read) begin 
                index <= index + 1;
            end
        end 
    end

    always @(posedge internal_clk) begin 
        if ((0 == enable) && (0 == data_set) && (0 == is_read)) begin
            registers[data_in[8:15]] <= data_in[16:23];
            data_set <= 1;
        end
        else if (enable && (8 == index))
        begin
            is_read <= (8'hF0 != data_in[0:7]) ? 1 : 0;
        end
        if (is_read && (7 == read_index) && (0 == read_addr_set)) begin 
            addr_in <= addr_in + 1;
            read_addr_set <= 1;
        end
        oe_i[0] <= (registers[6] & 8'h02) == 8'h02;
        oe_i[1] <= (registers[8] & 8'h02) == 8'h02;
        if (0 == oe[0])
        begin
            registers[7] <= P13;
        end
        if (0 == oe[1])
        begin
            registers[9] <= P20;
        end
    end

endmodule