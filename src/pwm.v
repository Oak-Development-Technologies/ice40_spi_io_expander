module pwm(input clk, input en, input [5:0] value_input, output out);
   reg [5:0] counter;
   reg [5:0] value; // max 63

   assign out = (counter < value);

   initial begin
      counter = 0;
      value = 0;
   end

   always @(posedge clk)
   begin
      counter <= counter + 1;
      
      if(en == 1'b1) begin
        value <= value_input;
      end;
   end
endmodule
