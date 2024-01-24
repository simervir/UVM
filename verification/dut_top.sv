module dut_top(intf.dut i_intf);

xswitch dut_core(
    .clk(i_intf.clk),
    .reset(i_intf.reset),
    .addr_in(i_intf.addr_in),
    .data_in(i_intf.data_in),
    .valid_in(i_intf.valid_in),
    .rcv_rdy(i_intf.rcv_rdy),
    .addr_out(i_intf.addr_out),
    .data_out(i_intf.data_out),
    .data_rdy(i_intf.data_rdy),
    .data_read(i_intf.data_read)

);

endmodule