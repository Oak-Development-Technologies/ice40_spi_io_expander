`default_nettype none
module top(output [2:0] RGB, input clk, enable, data, output data_out);

    reg [0:7] registers [0:7];
    reg [0:7] addr_in;
    reg [0:15] data_in;

    reg [0:7] index;

    assign RGB[0] = (registers[0] == 8'hFF) ? registers[1] & 8'h01 : 1;
    assign RGB[1] = (registers[2] == 8'hFF) ? registers[3] & 8'h01 : 1;
    assign RGB[2] = (registers[4] == 8'hFF) ? registers[5] & 8'h01 : 1;
    //assign data_out = (registers[6] == 8'hFF) ? registers[7] & 8'h01 : 0;
    integer i;
    initial begin
        index = 0;
        data_in = 0;
        addr_in = 0;
        for (i = 0; i < 256; i= i + 1) begin
            registers[i] = 8'hFF;
        end
    end

    always @(posedge clk) begin

        if (enable) begin
            data_in[index] <= data;
            index <= index + 1;
        end
        else begin
            addr_in <= data_in[0:7];
            registers[data_in[0:7]] <= data_in[8:15];
            index <= 0;
        end
        //registers[7] <= P13;
        
    end

endmodule