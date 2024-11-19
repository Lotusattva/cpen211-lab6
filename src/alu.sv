`define ADD 2'b00
`define SUB 2'b01
`define AND_OP 2'b10
`define NOT_OP 2'b11


`define TRUE 16'b0000000000000000

module ALU(Ain, Bin, ALUop, out, status);
	input [15:0] Ain, Bin;
	input [1:0] ALUop;
	output [15:0] out;
	output [2:0] status;

	reg [15:0] out;
	reg [2:0] status;


	always_comb begin
		case (ALUop)
			`ADD: out = Ain + Bin;

			`SUB: out = Ain - Bin;

			`AND_OP: out = Ain & Bin;

			`NOT_OP: out = ~Bin;

			default: out = 16'bx;

		endcase
	end


	//Status register [2:0] Z
	// 0: Negative flag, N
	// 1: Overflow flag, V
	// 2: Zero flag, Z
	always_comb begin
		case (out[15]) //Negative flag, N
			1'b1: status[0] = 1'b1;

			default: status[0] = 1'b0;
		endcase

		case(ALUop)
			`ADD: begin //Z[1] = (Ain[15] & Bin[15] & ~out[15]) | (~Ain[15] & ~Bin[15] & out[15]);
				if ((Ain[15] === Bin[15]) && (Ain[15] !== out[15])) begin
					status[1] = 1'b1;
				end
				else begin
					status[1] = 1'b0;
				end
			end

			`SUB: begin //Z[1] = (Ain[15] & ~Bin[15] & ~out[15]) | (~Ain[15] & Bin[15] & out[15]);
				if ((Ain[15] !== Bin[15]) && (Ain[15] !== out[15])) begin
					status[1] = 1'b1;
				end

				else begin
					status[1] = 1'b0;
				end
			end

			default: status[1] = 1'b0;

		endcase


		case (out) //zero flag, Z
			`TRUE: status[2] = 1'b1;

			default: status[2] = 1'b0;
		endcase
	end



endmodule