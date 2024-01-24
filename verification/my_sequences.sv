`include "uvm_macros.svh"

package my_sequences;

    import uvm_pkg::*;

    class transaction extends uvm_sequence_item;
        `uvm_object_utils(transaction)

        rand logic [15:0] addr_in;
        rand logic [15:0] data_in;
        rand logic [3:0] valid_in;
        logic [3:0] rcv_rdy;
        logic [15:0] addr_out;
        logic [15:0] data_out;
        logic [3:0] data_rdy;
        rand logic [3:0] data_read;
        logic reset;
        constraint valid_addr{
            addr_in[3:0] <= 3;
            addr_in[7:4] <= 3;
            addr_in[11:8] <= 3;
            addr_in[15:12] <= 3;
        }

        function new (string name = "");
            super.new(name);
        endfunction: new

        function string convert2string;
            
            return $psprintf("reset:%0b,\naddr_in = %4h , data_in = %4h , valid_in =%4b , data_read=%4b, \naddr_out= %4h , data_out=%h ,  data_rdy=%4b , rcv_rdy= %4b: \n", 
            reset,
            addr_in, data_in, valid_in, data_read,
            addr_out, data_out, data_rdy, rcv_rdy);
        endfunction: convert2string
     endclass: transaction

    class unique_cons extends transaction;
        `uvm_object_utils(unique_cons)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint uniq_addr_in{ soft unique    {addr_in[3:0] ,
        addr_in[7:4] ,
        addr_in[11:8] ,
        addr_in[15:12]};}

    endclass: unique_cons

    class sanity_check extends transaction;
        `uvm_object_utils(sanity_check)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint addr_in_order{
        soft  {   addr_in == 16'h3210};
         }
        constraint all_valid{
          soft {  valid_in == 4'b1111};
         }
    endclass: sanity_check

    class all_valid_and_read extends transaction;
        `uvm_object_utils(all_valid_and_read)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint data_read_all{
          soft  {data_read == 4'b1111};
         }

        constraint valid_in_all{
            soft {valid_in == 4'b1111};
        }
    endclass: all_valid_and_read

    class port_0 extends transaction;
        `uvm_object_utils(port_0)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint data_port0{
          soft {data_read[0] == 1};
         }
        constraint addr_port0{
          soft {addr_in[3:0] == 0};

        }
        constraint valid_port0{
          soft {valid_in[0] == 1};
         }      

    endclass:port_0

    class port_1 extends transaction;
        `uvm_object_utils(port_1)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint data_port1{
          soft {data_read[1] == 1};
         }
        constraint addr_port1{
          soft {addr_in[7:4] == 1};

        }
        constraint valid_port1{
          soft {valid_in[1] == 1};
         }      

    endclass:port_1

    class port_2 extends transaction;
        `uvm_object_utils(port_2)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint data_port2{
          soft {data_read[2] == 1};
         }
        constraint addr_port2{
          soft {addr_in[11:8] == 2};

        }
        constraint valid_port2{
          soft {valid_in[2] == 1};
         }      

    endclass:port_2

    class port_3 extends transaction;
        `uvm_object_utils(port_3)
        function new (string name = "");
            super.new(name);
        endfunction: new
        constraint data_port3{
          soft {data_read[3] == 1};
         }
        constraint addr_port3{
          soft {addr_in[15:12] == 3};

        }
        constraint valid_port1{
          soft {valid_in[3] == 1};
         }      

    endclass:port_3




    class my_sequence extends uvm_sequence #(transaction);
        `uvm_object_utils(my_sequence)

        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            transaction tx;
            tx = transaction::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize());
            finish_item(tx);
        endtask
    endclass: my_sequence

    class seq_of_commands extends uvm_sequence #(transaction);
  
        `uvm_object_utils(seq_of_commands)
        `uvm_declare_p_sequencer(uvm_sequencer#(transaction))
        
        rand int n;
        
        function new (string name = "");
            super.new(name);
        endfunction: new

        task body;
            repeat(n)
            begin
                my_sequence seq;
                seq = my_sequence::type_id::create("seq");
                assert( seq.randomize() );
                seq.start(p_sequencer);
            end
        endtask: body
   
    endclass: seq_of_commands

endpackage: my_sequences