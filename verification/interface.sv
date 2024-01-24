
interface  intf(input bit clk,  reset);
        // ----
    logic [15:0] addr_in;
    logic [15:0] data_in;
    logic [3:0] valid_in;
    logic [3:0] rcv_rdy;
    logic [15:0] addr_out;
    logic [15:0] data_out;
    logic [3:0] data_rdy;
    logic [3:0] data_read;

    modport dut(
        output rcv_rdy, addr_out, data_out, data_rdy,
        input clk,reset, addr_in, data_in, valid_in, data_read
    );
    clocking driv_cb @(posedge clk);
        input rcv_rdy, addr_out, data_out, data_rdy;
        output addr_in, data_in, valid_in, data_read;
    endclocking

    modport drive(
        clocking driv_cb,
        input reset
    );
    clocking mon_cb @(posedge clk);
        input rcv_rdy, addr_out, data_out, data_rdy,
        addr_in, data_in, valid_in, data_read;
    endclocking

    modport mon(
        clocking mon_cb, 
        input reset
    );


    covergroup cg @(posedge clk);
        option.at_least = 3;
        cp_data_in: coverpoint data_in iff(reset==0){
            bins data_bin_low  = {16'h0000};        	
            bins data_bin_min = {[16'h0001:16'h000f]};
            bins data_bin_medium = {[16'h0010:16'h00ff]};
            bins data_bin_high = {[16'h0100:16'h0fff]};
            bins data_bin_large = {[16'h1000:16'hfffe]};
            bins data_bin_max = {16'hffff};
        }
        cp_data_out: coverpoint data_out iff(reset==0){
            bins data_bin_low  = {16'h0000};        	
            bins data_bin_min = {[16'h0001:16'h000f]};
            bins data_bin_medium = {[16'h0010:16'h00ff]};
            bins data_bin_high = {[16'h0100:16'h0fff]};
            bins data_bin_large = {[16'h1000:16'hfffe]};
            bins data_bin_max = {16'hffff};
        }

    
        cp_addr_in0: coverpoint addr_in[3:0] iff(reset==0){
        	bins a_port_0 = {0, 1 , 2 , 3};
            illegal_bins illegal_port0 = {[4'h4:4'hF]};
        }
        cp_addr_in1: coverpoint addr_in[7:4] iff(reset==0){
        	bins a_port_1 = {0, 1 , 2 , 3};
            illegal_bins illegal_port1 = {[4'h4:4'hF]};
        }
        cp_addr_in2: coverpoint addr_in[11:8] iff(reset==0){
        	bins a_port_2 = {0, 1 , 2 , 3};
            illegal_bins illegal_port2 = {[4'h4:4'hF]};
        }
        cp_addr_in3: coverpoint addr_in[15:12] iff(reset==0){
        	bins a_port_3 = {0, 1 , 2 , 3};
            illegal_bins illegal_port3 = {[4'h4:4'hF]};
        }

        cp_addr_out0: coverpoint addr_out[3:0] iff(reset==0){
        	bins a_port_0 = {0, 1 , 2 , 3};
            illegal_bins illegal_port0 = {[4'h4:4'hF]};
        }
        cp_addr_out1: coverpoint addr_out[7:4] iff(reset==0){
        	bins a_port_1 = {0, 1 , 2 , 3};
            illegal_bins illegal_port1 = {[4'h4:4'hF]};
        }
        cp_addr_out2: coverpoint addr_out[11:8] iff(reset==0){
        	bins a_port_2 = {0, 1 , 2 , 3};
            illegal_bins illegal_port2 = {[4'h4:4'hF]};
        }
        cp_addr_out3: coverpoint addr_out[15:12] iff(reset==0){
        	bins a_port_3 = {0, 1 , 2 , 3};
            illegal_bins illegal_port3 = {[4'h4:4'hF]};
        }

        cp_data_read0: coverpoint data_read[0] iff(reset==0){
        	bins read_min = {0};
            bins read_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_data_read1: coverpoint data_read[1] iff(reset==0){
        	bins read_min = {0};
            bins read_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_data_read2: coverpoint data_read[2] iff(reset==0){
        	bins read_min = {0};
            bins read_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_data_read3: coverpoint data_read[3] iff(reset==0){
        	bins read_min = {0};
            bins read_max = {1};
            bins transistion = (1'b0 => 1'b1); }

        cp_valid_in0: coverpoint valid_in[0] iff(reset==0){
        	bins valid_min = {0};
            bins valid_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_valid_in1: coverpoint valid_in[1] iff(reset==0){
        	bins valid_min = {0};
            bins valid_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_valid_in2: coverpoint valid_in[2] iff(reset==0){
        	bins valid_min = {0};
            bins valid_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_valid_in3: coverpoint valid_in[3] iff(reset==0){
        	bins valid_min = {0};
            bins valid_max = {1};
            bins transistion = (1'b0 => 1'b1); }

        cp_data_rdy0: coverpoint data_rdy[0] iff(reset==0){
        	bins data_rdy_min = {0};
            bins data_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_data_rdy1: coverpoint data_rdy[1] iff(reset==0){
        	bins data_rdy_min = {0};
            bins data_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_data_rdy2: coverpoint data_rdy[2] iff(reset==0){
        	bins data_rdy_min = {0};
            bins data_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_data_rdy3: coverpoint data_rdy[3] iff(reset==0){
        	bins data_rdy_min = {0};
            bins data_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        
        cp_rcv_rdy0: coverpoint rcv_rdy[0] {
        	bins rcv_rdy_min = {0};
            bins rcv_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_rcv_rdy1: coverpoint rcv_rdy[1]{
        	bins rcv_rdy_min = {0};
            bins rcv_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_rcv_rdy2: coverpoint rcv_rdy[2] {
        	bins rcv_rdy_min = {0};
            bins rcv_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }
        cp_rcv_rdy3: coverpoint rcv_rdy[3] {
        	bins rcv_rdy_min = {0};
            bins rcv_rdy_max = {1};
            bins transistion = (1'b0 => 1'b1); }


    endgroup
    cg cg_inst = new();

endinterface
