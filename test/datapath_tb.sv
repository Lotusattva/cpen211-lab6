//Shifter
`define NONE 2'b00
`define LEFT 2'b01
`define RIGHT 2'b10
`define SIGNED 2'b11

//ALUop
`define ADD 2'b00
`define SUB 2'b01
`define AND_OP 2'b10
`define NOT_OP 2'b11



module datapath_tb;
	reg [2:0] sim_writenum;
    reg [2:0] sim_readnum;
	reg [1:0] sim_shift;
    reg [1:0] sim_ALUop;
	reg [1:0] sim_vsel;
    reg sim_write;
    reg sim_clk;
    reg sim_loada;
    reg sim_loadb;
    reg sim_loadc;
    reg sim_loads;
    reg sim_asel;
    reg sim_bsel;
    
    reg [15:0] sim_mdata, sim_sximm5, sim_sximm8;
    reg [7:0] sim_PC;

	reg [15:0] sim_datapath_out;
	reg sim_Z_out, sim_N_out, sim_V_out;

    reg err;


    datapath DUT(.vsel(sim_vsel), .write(sim_write), .clk(sim_clk), .loada(sim_loada), .loadb(sim_loadb), .asel(sim_asel), .bsel(sim_bsel), .loadc(sim_loadc), .loads(sim_loads), .shift(sim_shift), .ALUop(sim_ALUop), .writenum(sim_writenum), .readnum(sim_readnum), .mdata(sim_mdata), .sximm5(sim_sximm5), .sximm8(sim_sximm8), .PC(sim_PC), .datapath_out(sim_datapath_out), .N(sim_N_out), .V(sim_V_out), .Z(sim_Z_out));

    initial begin
        //Set mdata and PC to 0
        sim_mdata = 16'd0;
        sim_PC = 8'd0;

        err = 1'b0;
        sim_loada = 1'b0;
        sim_loadb = 1'b0;
        sim_loadc = 1'b0;
        sim_loads = 1'b0;
        sim_write = 1'b0;


        //Test 1: MOV R0, #7
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd7;
        sim_vsel = 2'd2;
        sim_writenum = 3'd0;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R0 === 16'd7) $display("SUCCESS ** R0 is %b, expected %b", DUT.REGFILE.R0, 16'd7);
        else begin 
            $display("Fail: Test 1", DUT.REGFILE.R0);
            err = 1'b1;
        end



        //Test 2: MOV R1, #2
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd2;
        sim_vsel = 2'd2;
        sim_writenum = 3'd1;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R1 === 16'd2) $display("SUCCESS ** R1 is %b, expected %b", DUT.REGFILE.R1, 16'd2);
        else begin 
            $display("Fail: Test 2");
            err = 1'b1;
        end



        //Test 3: ADD R2, R1, R0, LSL #1 = #16
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd0; //store R0 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_shift = `LEFT; //shift left by #1

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd1; //store R1 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;
        


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD R0 and R1, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        assert (sim_datapath_out === 16'd16) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd16);
        else begin 
            $display("Fail: Test 3, Expected: %b, actual: %b", 16'd16, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 4, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 5, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 6, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end


        //Store in R2
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd2;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R2 === 16'd16) $display("SUCCESS ** R2 is %b, expected %b", DUT.REGFILE.R2, 16'd16);
        else begin 
            $display("Fail: Test 7");
            err = 1'b1;
        end

        sim_shift = `NONE; //reset shift
        #1;



        //Test 4: MOV R3, #42
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd42;
        sim_vsel = 2'd2;
        sim_writenum = 3'd3;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R3 === 16'd42) $display("SUCCESS ** R3 is %b, expected %b", DUT.REGFILE.R3, 16'd42);
        else begin 
            $display("Fail: Test 8", DUT.REGFILE.R3);
            err = 1'b1;
        end


        //Test 5: MOV R5, #13
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd13;
        sim_vsel = 2'd2;
        sim_writenum = 3'd5;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R5 === 16'd13) $display("SUCCESS ** R5 is %b, expected %b", DUT.REGFILE.R5, 16'd13);
        else begin 
            $display("Fail: Test 9");
            err = 1'b1;
        end


        

        //ADD R4, R5, R3
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd3; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd5; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        assert (sim_datapath_out === 16'd55) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd55);
        else begin 
            $display("Fail: Test 10, Expected: %b, actual: %b", 16'd55, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 11, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 12, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 13, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end


        //Store in R4
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd4;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R4 === 16'd55) $display("SUCCESS ** R4 is %b, expected %b", DUT.REGFILE.R4, 16'd55);
        else begin 
            $display("Fail: Test 14");
            err = 1'b1;
        end


        //Test MOV R7, R3 (R3 = #42)
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd3; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b1;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD #0 and R3, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        
        #1;
        assert (sim_datapath_out === 16'd42) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd42);
        else begin
            $display("Fail: Test 15, Expected: %b, actual: %b", 16'd42, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 16, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 17, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 18, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end


        //Store in R7
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd7;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R7 === 16'd42) $display("SUCCESS ** R7 is %b, expected %b", DUT.REGFILE.R7, 16'd42);
        else begin 
            $display("Fail: Test 19");
            err = 1'b1;
        end




        //SUB R6, R7, R7 (42 - 42 = 0)
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd7; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd7; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `SUB; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        assert (sim_datapath_out === 16'd0) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd0);
        else begin 
            $display("Fail: Test 20, Expected: %b, actual: %b", 16'd0, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out == 1'b1) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b1);
        else begin 
            $display("Fail: Test 21, Expected: %b, actual: %b", 1'b1, sim_Z_out);
            err = 1'b1;
        end

        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 22, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin
            $display("Fail: Test 23, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        
        //Store in R6
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd6;
        sim_write = 1'b1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R6 == 16'd0) $display("SUCCESS ** R6 is %b, expected %b", DUT.REGFILE.R6, 16'd0);
        else begin 
            $display("Fail: Test 24");
            err = 1'b1;
        end



        //AND R7, R7 (42 & 42 = 42 in bitwise)
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd7; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd7; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `AND_OP; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        assert (sim_datapath_out === 16'd42) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd42);
        else begin 
            $display("Fail: Test 25, Expected: %b, actual: %b", 16'd42, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 26, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end

        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 27, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 28, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end


        //Store in R7
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd7;
        sim_write = 1'b1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R7 == 16'd42) $display("SUCCESS ** R7 is %b, expected %b", DUT.REGFILE.R7, 16'd42);
        else begin 
            $display("Fail: Test 29");
            err = 1'b1;
        end



        //NOT R6, R6 (~R6 = 1)
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd6; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd6; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `NOT_OP; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        assert (sim_datapath_out == 16'b1111111111111111) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'b1111111111111111);
        else begin 
            $display("Fail: Test 30, Expected: %b, actual: %b", 16'b1111111111111111, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out == 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 31, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 32, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 33, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end


        //Store in R6
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd6;
        sim_write = 1'b1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R6 == 16'b1111111111111111) $display("SUCCESS ** R6 is %b, expected %b", DUT.REGFILE.R6, 16'b1111111111111111);
        else begin 
            $display("Fail: Test 34");
            err = 1'b1;
        end



        //Test: Add 16'b0 and sximm5
        sim_clk = 1'b0;
        #5;

        sim_sximm5 = -16'd1;
        sim_asel = 1'b1;
        sim_bsel = 1'b1;

        sim_ALUop = `ADD;
        #1;
        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        assert (sim_datapath_out == -16'd1) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, -16'd1);
        else begin 
            $display("Fail: Test 35, Expected: %b, actual: %b", -16'd1, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out == 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 36, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out == 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 37, Expected: %b, actual: %b", 1'b1, sim_Z_out);
            err = 1'b1;
        end

        #1;
        assert (sim_V_out == 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 38, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end


        //Store in R4
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd4;
        sim_write = 1'b1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R4 == -16'd1) $display("SUCCESS ** R4 is %b, expected %b", DUT.REGFILE.R4, -16'd1);
        else begin 
            $display("Fail: Test 39");
            err = 1'b1;
        end



        //Test MOV R7, R4 LSR #1
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd4; //store R4 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0
        sim_shift = `SIGNED;
        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b1;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD #0 and R4, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        
        #1;
        assert (sim_datapath_out == -16'd1) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, -16'd1);
        else begin
            $display("Fail: Test 40, Expected: %b, actual: %b", -16'd1, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out == 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 42, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end

        #1;
        assert (sim_V_out == 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 43, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        #1;
        assert (sim_N_out == 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 41, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end

        sim_shift = `NONE;


        //Store in R7
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd7;
        sim_write = 1'b1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R7 == -16'd1) $display("SUCCESS ** R7 is %b, expected %b", DUT.REGFILE.R7, -16'd1);
        else begin 
            $display("Fail: Test 42");
            err = 1'b1;
        end



        //Test 4: MOV R6, #32768
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd32768;
        sim_vsel = 2'd2;
        sim_writenum = 3'd6;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R6 == 16'd32768) $display("SUCCESS ** R6 is %b, expected %b", DUT.REGFILE.R6, 16'd32768);
        else begin 
            $display("Fail: Test 43");
            err = 1'b1;
        end



        //Test MOV R5, R6 Signed #1
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd6; //store R5 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0
        sim_shift = `SIGNED;
        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b1;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD #0 and R4, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        
        #1;
        assert (sim_datapath_out == 16'b1100000000000000) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'b1100000000000000);
        else begin
            $display("Fail: Test 44, Expected: %b, actual: %b", 16'b1100000000000000, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out == 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 45, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out == 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 46, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out == 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 47, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        sim_shift = `NONE;


        //Store in R7
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd7;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R7 == 16'b1100000000000000) $display("SUCCESS ** R7 is %b, expected %b", DUT.REGFILE.R7, 16'b1100000000000000);
        else begin 
            $display("Fail: Test 48");
            err = 1'b1;
        end



        //Test MOV R6, R4 Signed Right Shift #1
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd4; //store R4 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0
        sim_shift = `SIGNED;
        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b1;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD #0 and R4, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;

        
        #1;
        assert (sim_datapath_out == -16'd1) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, -16'd1);
        else begin
            $display("Fail: Test 49, Expected: %b, actual: %b", -16'd1, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out == 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 50, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out == 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 51, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out == 1'b0) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b0);
        else begin 
            $display("Fail: Test 52, Expected: %b, actual: %b", 1'b0, sim_V_out);
            err = 1'b1;
        end

        sim_shift = `NONE;


        //Store in R6
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd6;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R6 == -16'd1) $display("SUCCESS ** R6 is %b, expected %b", DUT.REGFILE.R6, -16'd1);
        else begin 
            $display("Fail: Test 53");
            err = 1'b1;
        end


        //Overflow Addition: Too negative
        
        //Test 4: MOV R3, #-32000
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = -16'd32000;
        sim_vsel = 2'd2;
        sim_writenum = 3'd3;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R3 === -16'd32000) $display("SUCCESS ** R3 is %b, expected %b", DUT.REGFILE.R3, -16'd32000);
        else begin 
            $display("Fail: Test 54", DUT.REGFILE.R3);
            err = 1'b1;
        end


        //Test 5: MOV R5, #-5000
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = -16'd5000;
        sim_vsel = 2'd2;
        sim_writenum = 3'd5;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R5 === -16'd5000) $display("SUCCESS ** R5 is %b, expected %b", DUT.REGFILE.R5, -16'd5000);
        else begin 
            $display("Fail: Test 55");
            err = 1'b1;
        end


        

        //ADD R4, R5, R3
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd3; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd5; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        assert (sim_datapath_out === 16'd28536) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd28536);
        else begin
            $display("Fail: Test 56, Expected: %b, actual: %b", 16'd28536, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 57, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin 
            $display("Fail: Test 58, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b1) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b1);
        else begin 
            $display("Fail: Test 59, Expected: %b, actual: %b", 1'b1, sim_V_out);
            err = 1'b1;
        end


        //Store in R4
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd4;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R4 === 16'd28536) $display("SUCCESS ** R4 is %b, expected %b", DUT.REGFILE.R4, 16'd28536);
        else begin 
            $display("Fail: Test 60");
            err = 1'b1;
        end



        //Overflow Addition: Too Positive
        //Test 4: MOV R3, #16000
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd16000;
        sim_vsel = 2'd2;
        sim_writenum = 3'd3;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R3 === 16'd16000) $display("SUCCESS ** R3 is %b, expected %b", DUT.REGFILE.R3, 16'd16000);
        else begin 
            $display("Fail: Test 61", DUT.REGFILE.R3);
            err = 1'b1;
        end


        //Test 5: MOV R5, #17000
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd17000;
        sim_vsel = 2'd2;
        sim_writenum = 3'd5;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R5 === 16'd17000) $display("SUCCESS ** R5 is %b, expected %b", DUT.REGFILE.R5, 16'd17000);
        else begin 
            $display("Fail: Test 62");
            err = 1'b1;
        end


        

        //ADD R4, R5, R3
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd3; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd5; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `ADD; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        assert (sim_datapath_out === -16'd32536) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, -16'd32536);
        else begin 
            $display("Fail: Test 63, Expected: %b, actual: %b", -16'd32536, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 64, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin 
            $display("Fail: Test 65, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b1) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b1);
        else begin 
            $display("Fail: Test 66, Expected: %b, actual: %b", 1'b1, sim_V_out);
            err = 1'b1;
        end


        //Store in R4
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd4;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R4 === -16'd32536) $display("SUCCESS ** R4 is %b, expected %b", DUT.REGFILE.R4, -16'd32536);
        else begin 
            $display("Fail: Test 67");
            err = 1'b1;
        end


        //Overflow Subtraction - Too Positive
        //Test 4: MOV R3, #-32767
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = -16'd32767;
        sim_vsel = 2'd2;
        sim_writenum = 3'd3;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R3 === -16'd32767) $display("SUCCESS ** R3 is %b, expected %b", DUT.REGFILE.R3, -16'd32767);
        else begin 
            $display("Fail: Test 68", DUT.REGFILE.R3);
            err = 1'b1;
        end


        //Test 5: MOV R5, #5
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd5;
        sim_vsel = 2'd2;
        sim_writenum = 3'd5;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R5 === 16'd5) $display("SUCCESS ** R5 is %b, expected %b", DUT.REGFILE.R5, 16'd5);
        else begin 
            $display("Fail: Test 69");
            err = 1'b1;
        end


        

        //SUB R4, R5, R3
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd5; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd3; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `SUB; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        assert (sim_datapath_out === 16'd32764) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, 16'd32764);
        else begin 
            $display("Fail: Test 70, Expected: %b, actual: %b", -16'd32764, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 71, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b0) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b0);
        else begin
            $display("Fail: Test 72, Expected: %b, actual: %b", 1'b0, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b1) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b1);
        else begin 
            $display("Fail: Test 73, Expected: %b, actual: %b", 1'b1, sim_V_out);
            err = 1'b1;
        end


        //Store in R4
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd4;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R4 === 16'd32764) $display("SUCCESS ** R4 is %b, expected %b", DUT.REGFILE.R4, 16'd32764);
        else begin 
            $display("Fail: Test 75");
            err = 1'b1;
        end




        //Overflow Subtraction - Too Negative
        //Test 4: MOV R3, #32767
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = 16'd32767;
        sim_vsel = 2'd2;
        sim_writenum = 3'd3;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R3 === 16'd32767) $display("SUCCESS ** R3 is %b, expected %b", DUT.REGFILE.R3, 16'd32767);
        else begin 
            $display("Fail: Test 76", DUT.REGFILE.R3);
            err = 1'b1;
        end


        //Test 5: MOV R5, #-1
        //
        //
        sim_clk = 1'b0;
        #5;

        sim_sximm8 = -16'd1;
        sim_vsel = 2'd2;
        sim_writenum = 3'd5;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R5 === -16'd1) $display("SUCCESS ** R5 is %b, expected %b", DUT.REGFILE.R5, -16'd1);
        else begin 
            $display("Fail: Test 77");
            err = 1'b1;
        end


        

        //SUB R4, R5, R3
        //
        //
        sim_clk = 1'b0; //Cycle 1
        #5;


        sim_readnum = 3'd5; //store R3 into Load B
        sim_loadb = 1'b1;
        #1; //Need this timer, otherwise too quick

        sim_clk = 1'b1;
        #1;

        sim_loadb = 1'b0; //reset Load B to 0

        sim_bsel = 1'b0;
    
        #1;
        

        sim_clk = 1'b0; //Cycle 2
        #5;

        sim_readnum = 3'd3; //store R5 into Load A
        sim_loada = 1'b1;
        #1;
        sim_clk = 1'b1;
        #1;
        sim_loada = 1'b0; //reset Load A to 0
        sim_asel = 1'b0;
        #1;


        sim_clk = 1'b0; //Cycle 3
        #5;

        sim_ALUop = `SUB; //ADD R3 and R5, then output
        #1;

        sim_loads = 1'b1;
        sim_loadc = 1'b1;
        #1;
        sim_clk = 1'b1;


        #1;
        assert (sim_datapath_out === -16'd32768) $display("SUCCESS ** Datapath_out is %b, expected %b", sim_datapath_out, -16'd32768);
        else begin 
            $display("Fail: Test 78, Expected: %b, actual: %b", -16'd32768, sim_datapath_out);
            err = 1'b1;
        end


        #1;
        assert (sim_Z_out === 1'b0) $display("SUCCESS ** Z is %b, expected %b", sim_Z_out, 1'b0);
        else begin 
            $display("Fail: Test 79, Expected: %b, actual: %b", 1'b0, sim_Z_out);
            err = 1'b1;
        end


        #1;
        assert (sim_N_out === 1'b1) $display("SUCCESS ** N is %b, expected %b", sim_N_out, 1'b1);
        else begin
            $display("Fail: Test 80, Expected: %b, actual: %b", 1'b1, sim_N_out);
            err = 1'b1;
        end


        #1;
        assert (sim_V_out === 1'b1) $display("SUCCESS ** V is %b, expected %b", sim_V_out, 1'b1);
        else begin 
            $display("Fail: Test 81, Expected: %b, actual: %b", 1'b1, sim_V_out);
            err = 1'b1;
        end


        //Store in R4
        sim_clk = 1'b0;
        #5;

        sim_vsel = 2'd0;
        sim_writenum = 3'd4;
        sim_write = 1'b1;
        #1;
        sim_clk = 1'b1;

        #1;
        sim_write = 1'b0;
        #1;
        assert (DUT.REGFILE.R4 === -16'd32768) $display("SUCCESS ** R4 is %b, expected %b", DUT.REGFILE.R4, -16'd32768);
        else begin 
            $display("Fail: Test 82");
            err = 1'b1;
        end



        if(~err) 
            $display("PASSED");
        else begin
            $display("FAILED");
        end
    end
endmodule