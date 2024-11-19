`define SELECT_RN 3'b100
`define SELECT_RD 3'b010
`define SELECT_RM 3'b001

`define Rn 8
`define Rd 5
`define Rm 0

`define sh 3
`define op 11
`define opcode 13


// responsible for selecting the read and write address, setting sximm8,
// and passing shift and ALU command to datapath
module instr_dec(in, opcode, op, nsel, readnum, writenum, sximm8, shift, ALUop);
    input [15:0] in;
    input [2:0] nsel;

    output [2:0] opcode, readnum, writenum;
    output [1:0] op, shift, ALUop;
    output [15:0] sximm8;

    reg [2:0] readnum, writenum;
    always_comb begin
        case (nsel)
            `SELECT_RN: begin
                readnum = in[`Rn+2:`Rn];
                writenum = in[`Rn+2:`Rn];
            end
            `SELECT_RD: begin
                readnum = in[`Rd+2:`Rd];
                writenum = in[`Rd+2:`Rd];
            end
            `SELECT_RM: begin
                readnum = in[`Rm+2:`Rm];
                writenum = in[`Rm+2:`Rm];
            end
            default: begin
                readnum = 3'bxxx;
                writenum = 3'bxxx;
            end
        endcase
    end

    assign sximm8 = {{8{in[7]}}, in[7:0]};

    assign opcode = in[`opcode+2:`opcode];
    assign ALUop = in[`op+1:`op];
    assign op = in[`op+1:`op];
    assign shift = in[`sh+1:`sh];
endmodule