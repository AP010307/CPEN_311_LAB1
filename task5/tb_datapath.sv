module tb_datapath();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
  
  logic slow_clock, fast_clock, resetb;
  logic load_pcard1, load_pcard2, load_pcard3;
  logic load_dcard1, load_dcard2, load_dcard3;
  logic [3:0] pcard3;
  logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
  logic [3:0] pscore, dscore;

  logic [6:0] HEX [0:5];
  assign HEX[0] = HEX0;
  assign HEX[1] = HEX1;
  assign HEX[2] = HEX2;
  assign HEX[3] = HEX3;
  assign HEX[4] = HEX4;
  assign HEX[5] = HEX5;

  initial #10000 $finish();

  initial slow_clock = 0;
  always #50 slow_clock = ~slow_clock;

  initial fast_clock = 0;
  always #2 fast_clock = ~fast_clock;

  datapath dp(.slow_clock(slow_clock),
              .fast_clock(fast_clock),
              .resetb(resetb),
              .load_pcard1(load_pcard1),
              .load_pcard2(load_pcard2),
              .load_pcard3(load_pcard3),
              .load_dcard1(load_dcard1),
              .load_dcard2(load_dcard2),
              .load_dcard3(load_dcard3),
              .dscore_out(dscore),
              .pscore_out(pscore),
              .pcard3_out(pcard3),
              .HEX5(HEX5),
              .HEX4(HEX4),
              .HEX3(HEX3),
              .HEX2(HEX2),
              .HEX1(HEX1),
              .HEX0(HEX0));

  // Assume all submodules work properly, will only test the load card and
  // reset functionality

  task automatic do_reset;
    begin
      resetb = 0;
        @(posedge slow_clock);   // reset takes effect here
      resetb = 1;              // release
      #1ps;                    // let comb settle (no extra posedge)
    end
  endtask
  
  task automatic test_load(
    ref logic load_card,
    input string name,
    input int active_idx,
    ref logic [6:0] HEX [0:5]
  );
  begin
    load_card = 1;
    @(posedge slow_clock);
    load_card = 0;
    
    #1 // Give some time to settling

    foreach (HEX[i]) begin // Check that only display associated with load_card are affected
      if (i == active_idx) begin
        assert(HEX[i] != 7'b1111111)
          else $fatal("ASSERT FAIL: HEX%0d did not update during %s", i, name);
      end
      else begin
        assert(HEX[i] == 7'b1111111)
          else $fatal("ASSERT FAIL: HEX%0d changed unexpectedly during %s", i, name);
      end
    end
  end
  endtask

  initial begin
    // Verify Reset
    do_reset();

    #10
    
    // Ensure all 7segs are reset
    foreach (HEX[i]) begin
        assert(HEX[i] == 7'b1111111)
        else $fatal(1, "ASSERT FAIL: HEX%0d did not reset", i);
    end

    assert(pcard3 == 4'd0)
    else $fatal(1, "ASSERT FAIL: pcard3 did not reset");
    assert(pscore == 4'd0)
    else $fatal(1, "ASSERT FAIL: pscore did not reset");

    assert(dscore == 4'd0)
    else $fatal(1, "ASSERT FAIL: dscore did not reset");
    // Test Loading
    do_reset();
    test_load(load_pcard1, "load_pcard1", 0, HEX);
    do_reset();
    test_load(load_pcard2, "load_pcard2", 1, HEX);
    do_reset();
    test_load(load_pcard3, "load_pcard3", 2, HEX);
    do_reset();
    test_load(load_dcard1, "load_dcard1", 3, HEX);
    do_reset();
    test_load(load_dcard2, "load_dcard2", 4, HEX);
    do_reset();
    test_load(load_dcard3, "load_dcard3", 5, HEX);



    $display("ALL TESTS PASSED :)");
    $finish;
  end
endmodule
