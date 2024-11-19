// nsel:
// 3'b001: Rm (always load to b)
// 3'b010: Rd (destination)
// 3'b100: Rn (always load to a except for MOV imm)

// opcode = 110, op = 10
// MOV Rn,#<im8> -> directly write im8 to Rn
// [nsel = 100, vsel = 10, write = 1]

// opcode = 110, op = 00
// MOV Rd,Rm{,<sh_op>} -> 0 + sh_Rm -> Rd
// [nsel = 001, loadb = 1] -> [loadc = 1, asel = 1] -> [nsel = 010, write = 1]



// Below instructions have the same sequence of operations
// opcode = 101
// op = 00
// ADD Rd,Rn,Rm{,<sh_op>} -> Rn + sh_Rm -> Rd
// op = 10
// AND Rd,Rn,Rm{,<sh_op>} -> Rn & sh_Rm -> Rd
// [nsel = 100, loada = 1] -> [nsel = 001, loadb = 1] -> [loadc = 1] -> [nsel = 010, write = 1]

// opcode = 101, op = 01
// CMP Rn,Rm{,<sh_op>} -> sh_Rm - Rn -> update status
// [nsel = 100, loada = 1] -> [nsel = 001, loadb = 1] -> [loads = 1]

// opcode = 101, op = 11
// MVN Rd,Rm{,<sh_op>} -> ~sh_Rm -> Rd
// [nsel = 001, loadb = 1] -> [loadc = 1, asel = 1] -> [nsel = 010, write = 1]



`define S_WAIT 3'd0
`define S_MOV_IMM 3'd1 // [nsel = 100, vsel = 10, write = 1]
`define S_READ_RN 3'd2 // [nsel = 100, loada = 1]
`define S_READ_RM 3'd3 // [nsel = 001, loadb = 1]
`define S_LOAD_C 3'd4 // [loadc = 1]
`define S_LOAD_C_WITHOUT_RN 3'd5 // [loadc = 1, asel = 1]
`define S_WRITE 3'd6 // [nsel = 010, write = 1]
`define S_LOAD_STATUS 3'd7 // [loads = 1]


// responsible for the control logic of the processor
module FSM(s, reset, clk, w, opcode, op, nsel, vsel, write, loada, loadb, asel, bsel, loadc, loads);
    input s, reset, clk;
    input [1:0] op;
    input [2:0] opcode;

    output w, write, loada, loadb, asel, bsel, loadc, loads;
    output [1:0] vsel;
    output [2:0] nsel;
endmodule