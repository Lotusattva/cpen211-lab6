`define NONE 2'b00
`define LEFT 2'b01
`define RIGHT 2'b10
`define SIGNED 2'b11



module shifter(in, shift, sout);
	input [15:0] in;
	input [1:0] shift;
	output [15:0] sout;
	
	reg [15:0] sout;
	
	always_comb begin
		case (shift)
			`LEFT: sout = in << 1;
			`RIGHT: sout = in >> 1;
			`SIGNED: sout = {in[15], in[15:1]}; //MSB gets in[15], otherwise right shift for other bits
			default: sout = in;
		endcase
	
	end


endmodule