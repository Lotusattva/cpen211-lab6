`define bus_width 5'b10000

//vsel
`define case0 2'b00
`define case1 2'b01
`define case2 2'b10
`define case3 2'b11

module datapath(vsel, write, clk, loada, loadb, asel, bsel, loadc, loads, shift, ALUop, writenum, readnum, mdata, sximm5, sximm8, PC, datapath_out, N, V, Z);
	input [15:0] mdata;
	input [15:0] sximm8;
	input [15:0] sximm5;
	input [7:0] PC;
	input [1:0] vsel;

	input [2:0] writenum, readnum;
	input [1:0] shift, ALUop;
	input write, clk, loada, loadb, loadc, loads, asel, bsel;
	
	output [15:0] datapath_out;
	output N, V, Z;
	
	reg [15:0] datapath_out;
	reg N, V, Z;



	reg [15:0] data_in;

	always_comb begin
		case (vsel)
			`case0: data_in = datapath_out;

			`case1: data_in = {8'b0, PC};

			`case2: data_in = sximm8;

			`case3: data_in = mdata;

		endcase
	end
	
	
	wire [15:0] data_out;
	
	regfile REGFILE(.data_in(data_in), .writenum(writenum), .write(write), .readnum(readnum), .clk(clk), .data_out(data_out));
	
	wire [15:0] load_a_out;
	wire [15:0] in;
	loadEnable #(`bus_width) load_a(.clk(clk), .en(loada), .in(data_out), .out(load_a_out));
	loadEnable #(`bus_width) load_b(.clk(clk), .en(loadb), .in(data_out), .out(in));
	
	
	wire [15:0] sout;
	shifter shifter_block(.in(in), .shift(shift), .sout(sout));
	
	
	wire [15:0] Ain;
	assign Ain = asel ? {16'b0} : load_a_out;
	
	
	wire [15:0] Bin;
	assign Bin = bsel ? sximm5 : sout;
	
	
	wire [15:0] out;
	wire [2:0] status_in;
	ALU alu(.Ain(Ain), .Bin(Bin), .ALUop(ALUop), .out(out), .Z(status_in));
	
	wire [2:0] status;

	loadEnable #(`bus_width) load_c(.clk(clk), .en(loadc), .in(out), .out(datapath_out));
	loadEnable #(3) status_reg(.clk(clk), .en(loads), .in(status_in), .out(status));

	assign N = status[0];
	assign V = status[1];
	assign Z = status[2];

endmodule