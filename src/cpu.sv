module cpu(clk, reset, s, load, in, out, N, V, Z, w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;

    wire [15:0] instr;
    vDFFE #(16) instruction_register(.clk(clk), .en(load), .in(in), .out(instr));

    wire [2:0] nsel, opcode;
    wire [1:0] op;
    wire [15:0] sximm8;

    wire [2:0] writenum, readnum;
    wire [1:0] vsel, shift, ALUop;
    wire write, loada, loadb, loadc, loads, asel, bsel;
    instr_dec instruction_decoder(.in(instr), .opcode(opcode), .op(op), .nsel(nsel), .readnum(readnum),
        .writenum(writenum), .sximm8(sximm8), .shift(shift), .ALUop(ALUop));

    FSM state_machine(.s(s), .reset(reset), .clk(clk), .w(w), .opcode(opcode), .op(op), .nsel(nsel),
        .vsel(vsel), .write(write), .loada(loada), .loadb(loadb), .asel(asel), .bsel(bsel),
        .loadc(loadc), .loads(loads));

    wire [7:0] PC;
    wire [15:0] mdata, sximm5;

    // what is sximm5 ????????
    assign PC = 8'b0;
    assign mdata = 16'b0;
    assign sximm5 = 16'b0;

    datapath DP(.vsel(vsel), .write(write), .clk(clk), .loada(loada), .loadb(loadb),
        .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads), .shift(shift), .ALUop(ALUop),
        .writenum(writenum), .readnum(readnum), .mdata(mdata), .sximm5(sximm5), .sximm8(sximm8),
        .PC(PC), .datapath_out(out), .N(N), .V(V), .Z(Z));

endmodule