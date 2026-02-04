module tb_statemachine();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
  logic player_win_light, dealer_win_light;
  logic fast_clock, slow_clock, resetb;
  logic load_pcard1, load_pcard2, load_pcard3;
  logic load_dcard1, load_dcard2, load_dcard3;
  logic [3:0] pscore, dscore;
  logic [3:0] pcard3;

  initial #10000 $finish();

  initial slow_clock = 0;
  always #5 slow_clock = ~slow_clock;

  statemachine dut (
    .slow_clock(slow_clock),
    .resetb(resetb),
    .dscore(dscore),
    .pscore(pscore),
    .pcard3(pcard3),
    .load_pcard1(load_pcard1),
    .load_pcard2(load_pcard2),
    .load_pcard3(load_pcard3),
    .load_dcard1(load_dcard1),
    .load_dcard2(load_dcard2),
    .load_dcard3(load_dcard3),
    .player_win_light(player_win_light),
    .dealer_win_light(dealer_win_light)
  );

  task automatic do_reset;
    begin
      resetb = 0;
      @(posedge slow_clock);
      resetb = 1;
      @(posedge slow_clock);
    end
  endtask
  
  task automatic test_reset();
    begin
      // Load Pcard 1 HIGH on reset since first card is always dealt in first
      // round
      do_reset(); 
      assert(load_pcard1 == 1)
      else $fatal("load_pcard1 not set to zero. Found %d", load_pcard1);

      assert(load_pcard2 == 0)
      else $fatal("load_pcard2 not set to zero");

      assert(load_pcard3 == 0)
      else $fatal("load_pcard3 not set to zero");

      assert(load_dcard1 == 0)
      else $fatal("load_dcard1 not set to zero");

      assert(load_dcard2 == 0)
      else $fatal("load_dcard2 not set to zero");

      assert(load_dcard3 == 0)
      else $fatal("load_dcard3 not set to zero");
  
      assert(player_win_light == 0)
      else $fatal("player_win_light not set to zero");

      assert(dealer_win_light == 0)
      else $fatal("dealer_win_light not set to zero");
    end
    endtask

  task automatic test_deal_2_cards();
    // Run the clock and verify that the correct signals go high and low
    begin
      do_reset();

      // load_pcard1 Loaded on reset
      assert(load_pcard1)
      else $fatal("FSM doesn't load pcard1 on reset");

      // Check that next state deals dealer's first card
      @(posedge slow_clock);
      assert(load_dcard1)
      else $fatal("FSM doesn't load dcard1 after pcard1");

      // Check that next state deals player's second card
      @(posedge slow_clock);
      assert(load_pcard2)
      else $fatal("FSM doesn't load pcard2 after dcard1");

      // Check that next state deals dealer's second card
      @(posedge slow_clock)
      assert(load_dcard2)
      else $fatal("FSM doesn't load dcard2 after pcard2");
    end
    endtask

  initial begin
    test_reset();

    #10

    // test_deal_2_cards();
    $display("ALL TESTS PASSED");
    $finish;
  end

endmodule
