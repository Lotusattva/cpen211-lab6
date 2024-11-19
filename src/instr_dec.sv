module instr_dec(in, nsel, ALUop, sximm5, sximm8, shift, readnum, writenum, opcode, op);
    input [15:0] in;
    input [1:0] nsel;

    output [1:0] ALUop;
    output [15:0] sximm5;
    output [15:0] sximm8;
    output [1:0] shift;
    output [3:0] readnum, writenum;
    output [2:0] opcode;
    output [1:0] op;


    reg [3:0] readnum, writenum;


    assign opcode = in[15:13];
    assign op = in[12:11];
    assign ALUop = in[12:11];


    assign sximm5 = {{11{in[4]}}, in[4:0]};
    assign sximm8 = {{8{in[7]}}, in[7:0]};

    assign shift = in[4:3];


    always_comb begin
        case (nsel)
            2'b00: begin
                readnum = in[10:8];
                writenum = in[10:8];
            end

            2'b01: begin
                readnum = in[7:5];
                writenum = in[7:5];
            end

            2'b10: begin
                readnum = in[2:0];
                writenum = in[2:0];
            end

            default: begin
                readnum = 3'bx;
                writenum = 3'bx;
            end
        endcase
    end


endmodule