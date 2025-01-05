module bidir(input oe, clk, inp, output outp, inout bidir);

reg a;
reg b;

assign bidir = oe ? a : 1'bZ;
assign outp = b;

always @(posedge clk) begin 
    b <= bidir;
    a <= inp;
end

endmodule

// flow of bidirectional flow
// oe = 1
// outp = b = bidir = a
// oe = 0
// outp = b = bidir = 1'bZ (whatever drives bidir drives b and drives outp)