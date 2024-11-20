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