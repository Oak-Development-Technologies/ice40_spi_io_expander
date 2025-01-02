module pwm(input clk, input en, input [0:6] value_input, output out);
   reg [0:7] counter;
   reg [0:6] value; //max 127

   assign out = (counter < value);

   initial begin
      counter = 0;
      value = 127;
   end

   always @(posedge clk)
   begin
      counter <= counter + 1;
      
      if(en == 1'b1) begin
        value <= value_input;
      end;
   end
endmodule