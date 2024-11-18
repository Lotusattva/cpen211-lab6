`define bus_width 5'b10000
`define Select_0  8'b00000001
`define Select_1  8'b00000010
`define Select_2  8'b00000100
`define Select_3  8'b00001000
`define Select_4  8'b00010000
`define Select_5  8'b00100000
`define Select_6  8'b01000000
`define Select_7  8'b10000000


module regfile(data_in, writenum, write, readnum, clk, data_out);
	input [15:0] data_in;
	input [2:0] writenum, readnum;
	input write, clk;
	output [15:0] data_out;
	
	reg [15:0] data_in;
	reg [15:0] data_out;
	
	wire [7:0] write_out; //output of 3:8 write decoder
	decoder #(3, 8) writeDecoder(writenum, write_out);
	
	//Load Enable
	wire in0 = write & write_out[0];
	wire in1 = write & write_out[1];
	wire in2 = write & write_out[2];
	wire in3 = write & write_out[3];
	wire in4 = write & write_out[4];
	wire in5 = write & write_out[5];
	wire in6 = write & write_out[6];
	wire in7 = write & write_out[7];
	
	
	//Output of load enable registers
	wire [15:0] R0;
	wire [15:0] R1;
	wire [15:0] R2;
	wire [15:0] R3;
	wire [15:0] R4;
	wire [15:0] R5;
	wire [15:0] R6;
	wire [15:0] R7;
	
	//Create load enable for all registers
	loadEnable #(`bus_width) load0(.clk(clk), .en(in0), .in(data_in), .out(R0));
	loadEnable #(`bus_width) load1(.clk(clk), .en(in1), .in(data_in), .out(R1));
	loadEnable #(`bus_width) load2(.clk(clk), .en(in2), .in(data_in), .out(R2));
	loadEnable #(`bus_width) load3(.clk(clk), .en(in3), .in(data_in), .out(R3));
	loadEnable #(`bus_width) load4(.clk(clk), .en(in4), .in(data_in), .out(R4));
	loadEnable #(`bus_width) load5(.clk(clk), .en(in5), .in(data_in), .out(R5));
	loadEnable #(`bus_width) load6(.clk(clk), .en(in6), .in(data_in), .out(R6));
	loadEnable #(`bus_width) load7(.clk(clk), .en(in7), .in(data_in), .out(R7));
	
	wire [7:0] read_out; //output of 3:8 read decoder
	decoder #(3, 8) readDecoder(.a(readnum), .b(read_out));
	
	
	always_comb begin
		case (read_out)
			`Select_0: data_out = R0;
			`Select_1: data_out = R1;
			`Select_2: data_out = R2;
			`Select_3: data_out = R3;
			`Select_4: data_out = R4;
			`Select_5: data_out = R5;
			`Select_6: data_out = R6;
			`Select_7: data_out = R7;
			default: data_out = 15'bx;
		endcase
	end
	
endmodule