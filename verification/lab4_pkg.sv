`include "uvm_macros.svh"

package lab4_pkg;
    import uvm_pkg::*;
    import my_sequences::*;
    
    typedef uvm_sequencer #(transaction) sequencer;


    //////////////////////////////////////////////////////////////
    // add the classes here   
    //////////////////////////////////////////////////////////////

    //config
    ///////////////////////////////////////////////
    class my_dut_config extends uvm_object;
        `uvm_object_utils(my_dut_config)

        function new(string name = "");
        super.new(name);
        endfunction

        virtual intf dut_vi;   
    endclass: my_dut_config


    //DRIVER
    /////////////////////////////////////////////
    class driver extends uvm_driver #(transaction);
        `uvm_component_utils(driver)

        my_dut_config dut_config;
        virtual intf dut_vi;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            assert( uvm_config_db #(my_dut_config)::get(this, "", "dut_config", 
                                dut_config) );
            dut_vi = dut_config.dut_vi;
        endfunction: build_phase


        task run_phase(uvm_phase phase);
            forever
            begin
                transaction tx;
                @(dut_vi.driv_cb);
                seq_item_port.get(tx);
                dut_vi.driv_cb.addr_in <= tx.addr_in;
                dut_vi.driv_cb.data_in <= tx.data_in;
                dut_vi.driv_cb.data_read <= tx.data_read;
                dut_vi.driv_cb.valid_in <= tx.valid_in; 
            end
        endtask: run_phase

    endclass: driver

    //monitor
    //////////////////////////////////////////
    class monitor extends uvm_monitor;
        `uvm_component_utils(monitor)

        uvm_analysis_port #(transaction) aport;

        my_dut_config dut_config;
        virtual intf.mon dut_vi;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            dut_config = my_dut_config::type_id::create("config");
            aport = new("aport", this);
            assert( uvm_config_db #(my_dut_config)::get(this, "", "dut_config",
                                dut_config) );
            dut_vi = dut_config.dut_vi;
        endfunction : build_phase

        task run_phase(uvm_phase phase);
            transaction tx1;
            transaction tx2;
            tx1 = transaction::type_id::create("tx1");
            tx2 = transaction::type_id::create("tx2");
            tx2.reset = dut_vi.reset;
            @(dut_vi.mon_cb);
            forever
            begin

               @(dut_vi.mon_cb);
                //tx1 = transaction::type_id::create("tx1");
                tx1.addr_in = dut_vi.mon_cb.addr_in;
                tx1.data_in = dut_vi.mon_cb.data_in;
                tx1.data_read = dut_vi.mon_cb.data_read;
                tx1.valid_in = dut_vi.mon_cb.valid_in;
                tx1.reset = dut_vi.reset;

                tx2.addr_out = dut_vi.mon_cb.addr_out;
                tx2.data_out = dut_vi.mon_cb.data_out;
                tx2.rcv_rdy = dut_vi.mon_cb.rcv_rdy;
                tx2.data_rdy = dut_vi.mon_cb.data_rdy;
                aport.write(tx2);
                @(dut_vi.mon_cb);
                //tx2 = transaction::type_id::create("tx2");
                tx2.addr_in = dut_vi.mon_cb.addr_in;
                tx2.data_in = dut_vi.mon_cb.data_in;
                tx2.data_read = dut_vi.mon_cb.data_read;
                tx2.valid_in = dut_vi.mon_cb.valid_in;
                tx2.reset = dut_vi.reset;

                tx1.addr_out = dut_vi.mon_cb.addr_out;
                tx1.data_out = dut_vi.mon_cb.data_out;
                tx1.rcv_rdy = dut_vi.mon_cb.rcv_rdy;
                tx1.data_rdy = dut_vi.mon_cb.data_rdy;
                
                //`uvm_info("Monitor", $psprintf("\n%s\n", tx2.convert2string()), UVM_NONE); 
                aport.write(tx1);
            end
        endtask: run_phase
    endclass: monitor 

    //agent 
    /////////////////////////////////////////
    class agent extends uvm_agent;

        `uvm_component_utils(agent)

        uvm_analysis_port #(transaction) aport;

        sequencer seq_h;
        driver driv_h;
        monitor mon_h;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new
        
        function void build_phase(uvm_phase phase);
            aport = new("aport", this);
            seq_h = sequencer::type_id::create("seq_h", this);
            driv_h = driver::type_id::create("driv_h"   , this);
            mon_h   = monitor::type_id::create("mon_h"  , this);
        endfunction: build_phase 

        function void connect_phase(uvm_phase phase);
           driv_h.seq_item_port.connect( seq_h.seq_item_export);
           mon_h.       aport.connect( aport );
        endfunction: connect_phase   
    endclass: agent

    //scoreboard
    ///////////////////////////////////////////////
    class scoreboard extends uvm_subscriber #(transaction);
        `uvm_component_utils(scoreboard)
        logic [15:0] addr_in;
        logic [15:0] data_in;
        logic [3:0] valid_in;
        logic [3:0] rcv_rdy;
        logic [15:0] addr_out;
        logic [15:0] data_out;
        logic [3:0] data_rdy;
        logic [3:0] data_read;
        logic reset;


        int j, i, prio;
        bit [3:0] sb_data_rdy, prev_data_rdy;
        logic [15:0] sb_data_out ;
        logic [15:0] sb_addr_out ;
        bit [3:0] sb_rcv_rdy ;
        int pass, failed;
        int error_addr_out, error_data_out, error_data_rdy, error_rcv_rdy;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void write(transaction t);
            //`uvm_info("Scoreboard", $psprintf("\n%s\n", t.convert2string()), UVM_NONE); 
            prev_data_rdy = sb_data_rdy;
            if(t.reset) 
                    sb_data_rdy = 4'b0000;
            else begin           
                    for(i = 0; i < 4; i = i + 1) begin
                        for(j = 0; j < 4; j = j + 1)begin
                            if(t.addr_in[4 * j +: 4] == i && t.valid_in[j])begin
                                    sb_data_rdy[i] = 1;
                                break;                  
                                end
                            end
                        if( j == 4) begin
                                if(t.data_read[i] == 1)
                                    sb_data_rdy[i] = 0;
                                else
                                    sb_data_rdy[i] = sb_data_rdy[i];        
                        end    
                    end
            end
            //data out ------------------------------
            if(t.reset) 
                sb_data_out = 16'hzzzz;
            else begin
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = 0; j < 4; j = j + 1) begin
                        if (t.addr_in[4 * j +: 4] == i && t.valid_in[j])begin
                            if ((prev_data_rdy[i] && t.data_read[i]) || (!prev_data_rdy[i]))begin
                                    sb_data_out [4 * i +: 4] = t.data_in [4 *j+: 4];
                            end
                            break;
                        end 
                        //break;
                    end
                end
            end 

            //addr out -------------------------------
            if(t.reset) 
                sb_addr_out = 16'hzzzz;
            else begin
                for (i = 0; i < 4; i = i + 1) begin
                    for (j = 0; j < 4; j = j + 1) begin
                        if (t.addr_in[4 * j +: 4] == i && t.valid_in[j])begin
                            if ((prev_data_rdy[i] && t.data_read[i]) || (!prev_data_rdy[i]))begin
                                    sb_addr_out[4 * i +: 4] = j;
                            end
                            break;
                        end 
                        //break;
                    end
                end
            end
            //rcv_rdy--------------------
            if(t.reset) 
                sb_rcv_rdy = 4'b1111;
            else begin
                for (i = 0; i < 4; i = i + 1) begin
                    prio = 0;
                    for(j = 0; j<4; j= j+1)begin
                        if (t.addr_in[4 * j +: 4] == i && t.valid_in[j])begin
                                if (((prev_data_rdy[i] && t.data_read[i]) || (!prev_data_rdy[i]))&& (!prio))begin
                                        sb_rcv_rdy[j] = 1;
                                        prio =1;
                                end
                                else
                                    sb_rcv_rdy[j] = 0;   
                        end
                    end
                end
            end

            //checker------------------------------------------
            if(t.data_rdy === sb_data_rdy) begin
                pass = pass+1;
                error_data_rdy = 0;
            end
            else begin
                failed = failed +1;
                error_data_rdy = 1;
            end
            
            if(t.data_out === sb_data_out)begin

                pass = pass+1;
                error_data_out = 0;
            end
            else begin

                failed = failed +1;
                error_data_out = 1;
            end
            if(t.addr_out === sb_addr_out) begin
                pass = pass+1;
                error_addr_out = 0;
            end
            else begin

                failed = failed +1;
                error_addr_out = 1;
            end
            if(t.rcv_rdy == sb_rcv_rdy) begin
                pass = pass+1;
                error_rcv_rdy = 0;
            end
            else begin

                failed = failed +1;
                error_rcv_rdy = 1;
            end
            if(error_data_out||error_addr_out||error_rcv_rdy||error_data_rdy)begin
                if(error_data_rdy)
                `uvm_info("Scoreboard", $psprintf("\nExpected Scb_data_rdy:%4b recieved data_rdy:%4h\n", sb_data_rdy,  t.data_rdy),UVM_NONE );
                if(error_addr_out)
                `uvm_info("Scoreboard", $psprintf("\nExpected Scb_addr_out:%4h recieved addr_out:%4h\n", sb_addr_out,  t.addr_out),UVM_NONE );
                if(error_data_out)
                `uvm_info("Scoreboard", $psprintf("\nExpected Scb_data_out:%4h recieved data_out:%4h\n", sb_data_out,  t.data_out),UVM_NONE );                
                if(error_rcv_rdy)
                `uvm_info("Scoreboard", $psprintf("\nExpected Scb_rcv_rdy:%4b recieved rcv_rdy:%4b\n", sb_rcv_rdy,  t.rcv_rdy),UVM_NONE );

                `uvm_info("Scoreboard", $psprintf("\n%s error----//--------------------------------------------------------------\n\n", t.convert2string()), UVM_NONE);       
            end

        endfunction: write
        function void report;
                `uvm_info("Scoreboard", $psprintf("\n\nTotal Passed:%d , Total Failed:%d\n\n" , pass, failed), UVM_NONE);
        endfunction
    endclass: scoreboard

    //environment
    //////////////////////////////////////////////
    class  environment extends uvm_env;
        `uvm_component_utils(environment)
        
        agent agent_h;
        scoreboard scb_h;
        UVM_FILE file_h;
        function new(string name, uvm_component parent);
                super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            agent_h = agent::type_id::create("agent_h", this);
            scb_h =scoreboard::type_id::create("scb_h", this);
        endfunction: build_phase
        
        function void connect_phase(uvm_phase phase);
            agent_h.aport.connect( scb_h.analysis_export );
        endfunction: connect_phase
        
        function void start_of_simulation_phase(uvm_phase phase);
        
        uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
        file_h = $fopen("uvm_basics_complete.log", "w");
        uvm_top.set_report_default_file_hier(file_h);
        uvm_top.set_report_severity_action_hier(UVM_INFO, UVM_DISPLAY + UVM_LOG);

        endfunction: start_of_simulation_phase
    endclass

    //test
    ////////////////////////////////////////
    
    class test extends uvm_test;  
        `uvm_component_utils(test)

        my_dut_config dut_config;   
        environment env_h;   
        
        int max_case = 10;
        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new
        
        function void build_phase(uvm_phase phase);
            dut_config = new();
            if(!uvm_config_db #(virtual intf)::get( this, "", "dut_vi", 
						  dut_config.dut_vi))
            `uvm_fatal("NOVIF", "No virtual interface set")
            uvm_config_db #(my_dut_config)::set(this, "*", "dut_config", 
                            dut_config);
            env_h = environment::type_id::create("env_h", this);
        endfunction: build_phase   
    endclass: test

    class base_test extends test;
        `uvm_component_utils(base_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");

        //    seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: base_test
        
    class sanity_check_test extends test;
        `uvm_component_utils(sanity_check_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(sanity_check::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
        //    seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: sanity_check_test


    class unique_test extends test;
        `uvm_component_utils(unique_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(unique_cons::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
          //  seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: unique_test


    class all_valid_and_read_test extends test;
        `uvm_component_utils(all_valid_and_read_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(all_valid_and_read::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
        //            seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: all_valid_and_read_test

    class port_0_test extends test;
        `uvm_component_utils(port_0_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(port_0::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
        //            seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: port_0_test

    class port_1_test extends test;
        `uvm_component_utils(port_1_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(port_1::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
        //            seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: port_1_test

    class port_2_test extends test;
        `uvm_component_utils(port_2_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(port_2::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
        //            seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: port_2_test

    class port_3_test extends test;
        `uvm_component_utils(port_3_test)


        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction: new

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            transaction::type_id::set_type_override(port_3::get_type());
        endfunction
        task run_phase(uvm_phase phase);
            seq_of_commands seq;
            seq = seq_of_commands::type_id::create("seq");
        //            seq.how_many.constraint_mode(0);
            assert( seq.randomize() with {seq.n > 5 && seq.n < max_case;});
            phase.raise_objection(this);
            seq.start(env_h.agent_h.seq_h);
            phase.drop_objection(this);
        endtask // run_phase
    endclass: port_3_test


endpackage: lab4_pkg