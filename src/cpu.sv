module cpu(clk, reset, s, load, in, out, N, V, Z, w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;

    wire [15:0] instr_out;
    vDFFE instruction_register(.clk(clk), .en(load), .in(in), .out(instr_out));

    wire [1:0] ALUop;
    wire [15:0] sximm5;
    wire [15:0] sximm8;
    wire [1:0] shift;
    wire [2:0] readnum;
    wire [2:0] writenum;
    wire [2:0] opcode;
    wire [1:0] op;
    wire [1:0] nsel;

    instr_dec instr_decode(.in(instr_out), .nsel(nsel), .ALUop(ALUop), .sximm5(sximm5), .sximm8(sximm8), .shift(shift), .readnum(readnum), .writenum(writenum), .opcode(opcode), .op(op));

    stateMachine controller()

    datapath DP(vsel, write, .clk(clk), loada, loadb, asel, bsel, loadc, loads, .shift(shift), .ALUop(ALUop), .writenum(writenum), .readnum(readnum), mdata, .sximm5(sximm5), .sximm8(sximm8), PC, datapath_out, N, V, Z);




endmodule