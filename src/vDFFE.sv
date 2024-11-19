module vDFFE(clk, en, in, out);
	parameter n = 1;  // width
	input clk, en;
	input  [n-1:0] in;
	output reg [n-1:0] out;

	always_ff @(posedge clk)
		out <= en ? in : out;
endmodule
