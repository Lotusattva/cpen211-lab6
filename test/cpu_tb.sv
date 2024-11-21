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

        sim_reset = 1'b1;
        #1;
        sim_reset = 1'b0;
        //Initially in w stage
        assert (sim_w_out === 1'b1) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b1);
        else begin 
            $display("Fail: Test 1");
            err = 1'b1;
        end


        //MOV R0, #7
        sim_in = 16'b1101000000000111;
        sim_load = 1'b1;

        #1;
        sim_clk = 1'b1;

        //start instruction
        sim_s = 1'b1;

        assert (sim_w_out === 1'b0) $display("SUCCESS ** w is %b, expected %b", sim_w_out, 1'b0);
        else begin 
            $display("Fail: Test 2");
            err = 1'b1;
        end


        






        if(~err) 
            $display("PASSED");
        else begin
            $display("FAILED");
        end
    end

endmodule