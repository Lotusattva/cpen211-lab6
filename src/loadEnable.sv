module loadEnable(clk, en, in, out);
	parameter n = 1;  // width
	input clk, en;
	input  [n-1:0] in;
	output [n-1:0] out;
	
	reg    [n-1:0] out;
	wire   [n-1:0] next_out;

	assign next_out = en ? in : out;

	always @(posedge clk) begin
		out = next_out;
	end
endmodule
