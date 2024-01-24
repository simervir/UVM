`include "uvm_macros.svh"
module top();
    import uvm_pkg:: *;
    import lab4_pkg:: *;

    bit clk =0;
    bit reset  =1;
    intf i_intf(.clk(clk),  .reset(reset));
    dut_top dut(.i_intf(i_intf));

    // clock 
    initial
    begin
        clk = 0;
        forever #5 clk = ~clk;
    end 

    //reset
    initial
    begin

        repeat(3)@(negedge clk);
        reset = 0;
    end

    initial begin
        uvm_config_db #(virtual intf)::set(null, "uvm_test_top","dut_vi", i_intf);
        uvm_top.finish_on_completion  = 1; // completion of the test 
        run_test("test");
    end
endmodule 