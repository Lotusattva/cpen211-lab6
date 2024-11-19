module cpu(clk, reset, s, load, in, out, N, V, Z, w);
    input clk, reset, s, load;
    input [15:0] in;
    output [15:0] out;
    output N, V, Z, w;

    wire [15:0] instr_out;
    vDFFE instruction_register(.clk(clk), .en(load), .in(in), .out(instr_out));

    wire [15:0] sximm5, sximm8, mdata;
    wire [7:0] PC;
    wire [2:0] writenum, readnum;
    wire [1:0] vsel, shift, ALUop;
    wire write, loada, loadb, loadc, loads, asel, bsel;

    datapath DP(.vsel(vsel), .write(write), .clk(clk), .loada(loada), .loadb(loadb),
        .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads), .shift(shift), .ALUop(ALUop),
        .writenum(writenum), .readnum(readnum), .mdata(mdata), .sximm5(sximm5), .sximm8(sximm8),
        .PC(PC), .datapath_out(out), .N(N), .V(V), .Z(Z));

endmodule