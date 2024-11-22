`define S_WAIT 4'd0              // everything set to 0
`define S_MOV_IMM_RN 4'd1        // [nsel = 100, vsel = 10, write = 1]
`define S_READ_RN 4'd2           // [nsel = 100, loada = 1]
`define S_READ_RM 4'd3           // [nsel = 001, loadb = 1]
`define S_LOAD_C 4'd4            // [loadc = 1]
`define S_LOAD_C_WITHOUT_RN 4'd5 // [loadc = 1, asel = 1]
`define S_WRITE_RD 4'd6          // [nsel = 010, write = 1]
`define S_LOAD_STATUS 4'd7       // [loads = 1]
`define S_DECODE 4'd8            // wait for instruction


module cpu_tb;
    reg sim_clk, sim_reset, sim_s, sim_load;
    reg [15:0] sim_in;

    reg [15:0] sim_out;
    reg sim_N_out, sim_V_out, sim_Z_out, sim_w_out;


    reg err;

    cpu DUT(.clk(sim_clk), .reset(sim_reset), .s(sim_s), .load(sim_load), .in(sim_in), .out(sim_out), .N(sim_N_out), .V(sim_V_out), .Z(sim_Z_out), .w(sim_w_out));


    initial begin
        sim_clk = 1'b0;
        sim_reset = 1'b0;
        sim_s = 1'b0;
        sim_load = 1'b0;
    

        err = 1'b0;
        #1;


        //Reset state machine to State Wait
        sim_reset = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_reset = 1'b0; //Initially in w stage
        #1;
        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 1");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 2");
            err = 1'b1;
        end


        //Set s = 1'b0
        sim_clk = 1'b0;
        #5;

        sim_s = 1'b0;
        #1;
        sim_clk = 1'b1; //Initially in w stage
        #1;
        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin
            $display("Fail: Test 3");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 4");
            err = 1'b1;
        end


        //Move to Decode stage
        sim_clk = 1'b0;
        #5;

        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;
        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin
            $display("Fail: Test 5", sim_w_out);
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 6");
            err = 1'b1;
        end


        //Reset state machine to State Wait
        sim_clk = 1'b0;
        #5;
        sim_reset = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_reset = 1'b0; //Initially in w stage
        #1;
        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 7");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 8");
            err = 1'b1;
        end


        //MOV R0, #7
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1101000000000111;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 9");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 10");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        #1;
        assert (DUT.DP.REGFILE.R0 === 16'd7) $display("SUCCESS ** R0 is %b, expected %b", DUT.DP.REGFILE.R0, 16'd7);
        else begin 
            $display("Fail: Test 11", DUT.DP.REGFILE.R0);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 12");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 13");
            err = 1'b1;
        end



        //MOV R1, #2
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1101000100000010;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 14");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 15");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        #1;
        assert (DUT.DP.REGFILE.R1 === 16'd2) $display("SUCCESS ** R1 is %b, expected %b", DUT.DP.REGFILE.R1, 16'd2);
        else begin 
            $display("Fail: Test 16", DUT.DP.REGFILE.R1);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 17");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 18");
            err = 1'b1;
        end



        //ADD R2, R1, R0, LSL #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1010000101001000;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 19");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 20");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 21");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 22");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C);
        else begin 
            $display("Fail: Test 23");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 24");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R2 === 16'd16) $display("SUCCESS ** R2 is %b, expected %b", DUT.DP.REGFILE.R2, 16'd16);
        else begin 
            $display("Fail: Test 25", DUT.DP.REGFILE.R2);
            err = 1'b1;
        end

        assert (sim_out === 16'd16) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd16);
        else begin 
            $display("Fail: Test 26", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 27");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 28");
            err = 1'b1;
        end



        //MOV R3, R1, LSL #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1100000001101001;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 29");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 30");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 31");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C_WITHOUT_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C_WITHOUT_RN);
        else begin 
            $display("Fail: Test 32");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 33");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R3 === 16'd4) $display("SUCCESS ** R3 is %b, expected %b", DUT.DP.REGFILE.R3, 16'd4);
        else begin 
            $display("Fail: Test 34", DUT.DP.REGFILE.R3);
            err = 1'b1;
        end

        assert (sim_out === 16'd4) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd4);
        else begin 
            $display("Fail: Test 35", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 36");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 37");
            err = 1'b1;
        end

        

        //MOV R4, #0
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1101010000000000;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 38");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 39");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        #1;
        assert (DUT.DP.REGFILE.R4 === 16'd0) $display("SUCCESS ** R4 is %b, expected %b", DUT.DP.REGFILE.R4, 16'd0);
        else begin 
            $display("Fail: Test 40", DUT.DP.REGFILE.R4);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 41");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 42");
            err = 1'b1;
        end



        //ADD R5, R4, R3, LSL #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1010010010101011;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 43");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 44");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 45");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 46");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C);
        else begin 
            $display("Fail: Test 47");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 48");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R5 === 16'd8) $display("SUCCESS ** R5 is %b, expected %b", DUT.DP.REGFILE.R5, 16'd8);
        else begin 
            $display("Fail: Test 49", DUT.DP.REGFILE.R5);
            err = 1'b1;
        end

        assert (sim_out === 16'd8) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd8);
        else begin 
            $display("Fail: Test 50", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 51");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 52");
            err = 1'b1;
        end



        //CMP R5, R3, LSL #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1010110100001011;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 53");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 54");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 55");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 56");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_STATUS) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_STATUS);
        else begin 
            $display("Fail: Test 57");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (sim_Z_out === 1'b1) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b1);
        else begin 
            $display("Fail: Test 58, Expected: %b, actual: %b", 1'b1, sim_Z_out);
            err = 1'b1;
        end

        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 59, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end

        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 60, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 61");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 62");
            err = 1'b1;
        end


        
        //ADD R6, R4, R3, RSR #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1010010011011011;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 63");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 64");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 65");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 66");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C);
        else begin 
            $display("Fail: Test 67");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 68");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R6 === 16'd2) $display("SUCCESS ** R2 is %b, expected %b", DUT.DP.REGFILE.R6, 16'd2);
        else begin 
            $display("Fail: Test 69", DUT.DP.REGFILE.R6);
            err = 1'b1;
        end

        assert (sim_out === 16'd2) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd2);
        else begin 
            $display("Fail: Test 70", sim_out);
            err = 1'b1;
        end

        assert (sim_out === 16'd2) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd2);
        else begin 
            $display("Fail: Test 71", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 72");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 73");
            err = 1'b1;
        end



        //MOV R7, R1, RSR #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1100000011111001;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 74");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 75");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 76");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C_WITHOUT_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C_WITHOUT_RN);
        else begin 
            $display("Fail: Test 77");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 78");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R7 === 16'd1) $display("SUCCESS ** R3 is %b, expected %b", DUT.DP.REGFILE.R7, 16'd1);
        else begin 
            $display("Fail: Test 79", DUT.DP.REGFILE.R7);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 80");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 81");
            err = 1'b1;
        end


        //MOV R0, R1, RSR #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1100000000011001;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 82");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 83");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 84");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C_WITHOUT_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C_WITHOUT_RN);
        else begin 
            $display("Fail: Test 85");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 86");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R0 === 16'd1) $display("SUCCESS ** R3 is %b, expected %b", DUT.DP.REGFILE.R0, 16'd1);
        else begin 
            $display("Fail: Test 87", DUT.DP.REGFILE.R0);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 88");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 89");
            err = 1'b1;
        end




        //AND R3, R0, R7
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1011000001100111;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 90");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 91");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 92");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 93");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C);
        else begin 
            $display("Fail: Test 94");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 95");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R3 === 16'd1) $display("SUCCESS ** R3 is %b, expected %b", DUT.DP.REGFILE.R3, 16'd1);
        else begin 
            $display("Fail: Test 96", DUT.DP.REGFILE.R3);
            err = 1'b1;
        end

        assert (sim_out === 16'd1) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd1);
        else begin 
            $display("Fail: Test 97", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 98");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 99");
            err = 1'b1;
        end



        //AND R2, R0, R4
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1011000001000100;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 100");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 101");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 102");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 103");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C);
        else begin 
            $display("Fail: Test 104");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 105");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R2 === 16'd0) $display("SUCCESS ** R3 is %b, expected %b", DUT.DP.REGFILE.R2, 16'd0);
        else begin 
            $display("Fail: Test 106", DUT.DP.REGFILE.R2);
            err = 1'b1;
        end

        assert (sim_out === 16'd0) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd0);
        else begin 
            $display("Fail: Test 107", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 108");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 109");
            err = 1'b1;
        end



        //AND R3, R1, R3 LSL #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1011000101001011;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 110");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 111");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 112");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 113");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C);
        else begin 
            $display("Fail: Test 114");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 115");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out AND instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R2 === 16'd2) $display("SUCCESS ** R2 is %b, expected %b", DUT.DP.REGFILE.R2, 16'd2);
        else begin 
            $display("Fail: Test 116", DUT.DP.REGFILE.R2);
            err = 1'b1;
        end

        assert (sim_out === 16'd2) $display("SUCCESS ** Out is %b, expected %b", sim_out, 16'd2);
        else begin 
            $display("Fail: Test 117", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 118");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 119");
            err = 1'b1;
        end




        //MVN R4, R4
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1011100010000100;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 120");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 121");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 122");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C_WITHOUT_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C_WITHOUT_RN);
        else begin 
            $display("Fail: Test 123");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 124");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R4 === -16'd1) $display("SUCCESS ** R4 is %b, expected %b", DUT.DP.REGFILE.R4, -16'd1);
        else begin 
            $display("Fail: Test 125", DUT.DP.REGFILE.R4);
            err = 1'b1;
        end

        assert (sim_out === -16'd1) $display("SUCCESS ** Out is %b, expected %b", sim_out, -16'd1);
        else begin 
            $display("Fail: Test 126", sim_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 127");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 128");
            err = 1'b1;
        end




        //MVN R5, R4
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1011100010100100;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 129");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 130");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 131");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C_WITHOUT_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C_WITHOUT_RN);
        else begin 
            $display("Fail: Test 132");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 133");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R5 === 16'd0) $display("SUCCESS ** R5 is %b, expected %b", DUT.DP.REGFILE.R5, 16'd0);
        else begin 
            $display("Fail: Test 134", DUT.DP.REGFILE.R5);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 135");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 136");
            err = 1'b1;
        end


        //MOV R0, #-128
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1101000010000000;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 137");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 138");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        #1;
        assert (DUT.DP.REGFILE.R0 === -16'd128) $display("SUCCESS ** R0 is %b, expected %b", DUT.DP.REGFILE.R0, -16'd128);
        else begin 
            $display("Fail: Test 139", DUT.DP.REGFILE.R0);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 140");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 141");
            err = 1'b1;
        end



        //MVN R5, R0 LSL #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1011100010101000;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 142");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 143");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 144");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_C_WITHOUT_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_C_WITHOUT_RN);
        else begin 
            $display("Fail: Test 145");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out MVN instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_WRITE_RD) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WRITE_RD);
        else begin 
            $display("Fail: Test 146");
            err = 1'b1;
        end

        sim_clk = 1'b0; //carry out instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.DP.REGFILE.R5 === 16'd255) $display("SUCCESS ** R5 is %b, expected %b", DUT.DP.REGFILE.R5, 16'd255);
        else begin 
            $display("Fail: Test 147", DUT.DP.REGFILE.R5);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 148");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 149");
            err = 1'b1;
        end


        //MOV R0, #0
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1101000000000000;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 150");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 151");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        #1;
        assert (DUT.DP.REGFILE.R0 === 16'd0) $display("SUCCESS ** R0 is %b, expected %b", DUT.DP.REGFILE.R0, 16'd0);
        else begin 
            $display("Fail: Test 152", DUT.DP.REGFILE.R0);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 153");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 154");
            err = 1'b1;
        end



        //CMP R0, R5
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1010100000000101;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 155");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 156");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 157");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 158");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_STATUS) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_STATUS);
        else begin 
            $display("Fail: Test 159");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 160, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end

        assert (sim_N_out === 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 161, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end

        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 162, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 163");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 164");
            err = 1'b1;
        end



        //MOV R4, #1
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1101010000000001;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 165");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 166");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;


        sim_clk = 1'b0; //carry out MOV instruction
        #5;
        sim_clk = 1'b1;
        #1;

        #1;
        assert (DUT.DP.REGFILE.R4 === 16'd1) $display("SUCCESS ** R4 is %b, expected %b", DUT.DP.REGFILE.R4, 16'd1);
        else begin 
            $display("Fail: Test 167", DUT.DP.REGFILE.R4);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 168");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 169");
            err = 1'b1;
        end


        //CMP R2, R4 LSL #1 (2-2 = 0)
        sim_clk = 1'b0;
        #5;

        sim_in = 16'b1010101000001100;
        sim_load = 1'b1; //Write instruction
        #1;
        sim_clk = 1'b1;
        #1;
        sim_load = 1'b0;


        sim_clk = 1'b0; //Move to Decode stage
        #5;
        sim_s = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_s = 1'b0;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 170");
            err = 1'b1;
        end

        assert (DUT.state === `S_DECODE) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_DECODE);
        else begin 
            $display("Fail: Test 171");
            err = 1'b1;
        end

        sim_clk = 1'b0; //enter ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RN) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RN);
        else begin 
            $display("Fail: Test 172");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_READ_RM) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_READ_RM);
        else begin 
            $display("Fail: Test 173");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (DUT.state === `S_LOAD_STATUS) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_LOAD_STATUS);
        else begin 
            $display("Fail: Test 174");
            err = 1'b1;
        end


        sim_clk = 1'b0; //carry out ADD instruction
        #5;
        sim_clk = 1'b1;
        #1;

        assert (sim_Z_out === 1'b1) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b1);
        else begin 
            $display("Fail: Test 175, Expected: %b, actual: %b", 1'b1, sim_Z_out);
            err = 1'b1;
        end

        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 176, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end

        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 177, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 178");
            err = 1'b1;
        end

        assert (DUT.state === `S_WAIT) $display("SUCCESS ** State is %b, expected %b", DUT.state, `S_WAIT);
        else begin 
            $display("Fail: Test 179");
            err = 1'b1;
        end



        if(~err) 
            $display("PASSED");
        else begin
            $display("FAILED");
        end
    end

endmodule