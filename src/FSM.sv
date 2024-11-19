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

`define SELECT_RN 3'b100
`define SELECT_RD 3'b010
`define SELECT_RM 3'b001

`define S_WAIT 4'd0              // everything set to 0
`define S_MOV_IMM_RN 4'd1        // [nsel = 100, vsel = 10, write = 1]
`define S_READ_RN 4'd2           // [nsel = 100, loada = 1]
`define S_READ_RM 4'd3           // [nsel = 001, loadb = 1]
`define S_LOAD_C 4'd4            // [loadc = 1]
`define S_LOAD_C_WITHOUT_RN 4'd5 // [loadc = 1, asel = 1]
`define S_WRITE_RD 4'd6          // [nsel = 010, write = 1]
`define S_LOAD_STATUS 4'd7       // [loads = 1]
`define S_DECODE 4'd8            // wait for instruction

`define INSTR_MOV_IMM 5'b11010
`define INSTR_MOV 5'b11000
`define INSTR_ADD 5'b10100
`define INSTR_CMP 5'b10101
`define INSTR_AND 5'b10110
`define INSTR_MVN 5'b10111

// responsible for the control logic of the processor
module FSM(s, reset, clk, w, opcode, op, nsel, vsel, write, loada, loadb, asel, bsel, loadc, loads);
    input s, reset, clk;
    input [1:0] op;
    input [2:0] opcode;

    output w;
    output wire write, loada, loadb, asel, bsel, loadc, loads;
    output wire [1:0] vsel;
    output wire [2:0] nsel;

    reg [3:0] state;

    wire [4:0] instruction;
    assign instruction = {opcode, op};

    controller CONTROLLER(.state(state), .nsel(nsel), .vsel(vsel), .write(write), .loada(loada),
                          .loadb(loadb), .asel(asel), .bsel(bsel), .loadc(loadc), .loads(loads));

    assign w = (state == `S_WAIT) ? 1'b1 : 1'b0;

    always_ff @(posedge clk)
        if (reset)
            state <= `S_WAIT;

        else
            case (state)
                `S_WAIT:
                    if(s)
                        state <= `S_DECODE;
                    else
                        state <= `S_WAIT;
                `S_DECODE:
                    if (instruction == `INSTR_MOV_IMM)
                        state <= `S_MOV_IMM_RN;
                    else if (instruction == `INSTR_MOV || instruction == `INSTR_MVN)
                        state <= `S_READ_RM;
                    else if (instruction == `INSTR_ADD || instruction == `INSTR_AND ||
                             instruction == `INSTR_CMP)
                        state <= `S_READ_RN;
                    else
                        state <= `S_DECODE; // invalid instruction

                `S_MOV_IMM_RN:
                    state <= `S_WAIT;

                `S_READ_RN:
                    state <= `S_READ_RM;

                `S_READ_RM:
                    if (instruction == `INSTR_MOV || instruction == `INSTR_MVN)
                        state <= `S_LOAD_C_WITHOUT_RN;
                    else if (instruction == `INSTR_ADD || instruction == `INSTR_AND)
                        state <= `S_LOAD_C;
                    else if (instruction == `INSTR_CMP)
                        state <= `S_LOAD_STATUS;

                `S_LOAD_C:
                    state <= `S_WRITE_RD;

                `S_LOAD_C_WITHOUT_RN:
                    state <= `S_WRITE_RD;

                `S_WRITE_RD:
                    state <= `S_WAIT;

                `S_LOAD_STATUS:
                    state <= `S_WAIT;

                default:
                    state <= `S_WAIT; // invalid state
            endcase
endmodule

module controller(state, nsel, vsel, write, loada, loadb, asel, bsel, loadc, loads);
    input [3:0] state;

    output reg [2:0] nsel;
    output reg [1:0] vsel;
    output reg write, loada, loadb, asel, bsel, loadc, loads;

    always_comb
        case (state)
            // [nsel = 100, vsel = 10, write = 1]
            `S_MOV_IMM_RN: begin
                nsel = `SELECT_RN;
                vsel = 2'b10; // immediate value
                write = 1'b1; // write
                loada = 1'b0;
                loadb = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
            end
            // [nsel = 100, loada = 1]
            `S_READ_RN: begin
                nsel = `SELECT_RN;
                vsel = 2'bxx;
                write = 1'b0;
                loada = 1'b1; // load a
                loadb = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
            end
            // [nsel = 001, loadb = 1]
            `S_READ_RM: begin
                nsel = `SELECT_RM;
                vsel = 2'bxx;
                write = 1'b0;
                loada = 1'b0;
                loadb = 1'b1; // load b
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
            end
            // [loadc = 1]
            `S_LOAD_C: begin
                nsel = 3'bxxx;
                vsel = 2'bxx;
                write = 1'b0;
                loada = 1'b0;
                loadb = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b1; // load c
                loads = 1'b0;
            end
            // [loadc = 1, asel = 1]
            `S_LOAD_C_WITHOUT_RN: begin
                nsel = 3'bxxx;
                vsel = 2'bxx;
                write = 1'b0;
                loada = 1'b0;
                loadb = 1'b0;
                asel = 1'b1;  // asel
                bsel = 1'b0;
                loadc = 1'b1; // load c
                loads = 1'b0;
            end
            // [nsel = 010, write = 1]
            `S_WRITE_RD: begin
                nsel = `SELECT_RD;
                vsel = 2'b00;
                write = 1'b1; // write
                loada = 1'b0;
                loadb = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
            end
            // [loads = 1]
            `S_LOAD_STATUS: begin
                nsel = 3'bxxx;
                vsel = 2'bxx;
                write = 1'b0;
                loada = 1'b0;
                loadb = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b0;
                loads = 1'b1; // load status
            end
            // S_WAIT and S_DECODE
            default: begin
                nsel = 3'bxxx;
                vsel = 2'bxx;
                write = 1'b0;
                loada = 1'b0;
                loadb = 1'b0;
                asel = 1'b0;
                bsel = 1'b0;
                loadc = 1'b0;
                loads = 1'b0;
            end
        endcase
endmodule