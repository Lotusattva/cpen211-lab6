`define WAIT 7'd0
`define Decode_OPcode 7'd1
`define Decode_op 7'd2
`define Decode_ALUop 7'd3



module stateMachine(clk, opcode, op, s, reset, nsel, w, vsel, write, loada, loadb, asel, bsel, loadc, loads);
    input [2:0] opcode;
    input [1:0] op;
    input clk, s, reset;

    output [1:0] nsel, vsel;
    output write, loada, loadb, loadc, loads, asel, bsel;
    output w;


    reg [2:0] state; //stores state

    always_ff @(posedge clk) begin
        if (reset) begin
            state = `WAIT;
        end

        else begin
            case(state)
                `WAIT: begin
                    if (s) begin
                        state = `Decode_OPcode;
                    end
                    else begin
                        state = `WAIT;
                    end
                end

                `Decode_OPcode: begin
                    if (opcode == 3'b110) begin //MOV instructions
                        state = `Decode_op;
                    end
                    else if (opcode == 3'b101) begin
                        state = `Decode_ALUop;
                    end

                end


            endcase

        end

    end


    always_comb begin
        case (state)


        endcase
    end


endmodule