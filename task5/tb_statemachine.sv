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
      pscore = 3'd0;
      dscore = 3'd0;
      pcard3 = 4'd0;
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
      @(posedge slow_clock);
      assert(load_dcard2)
      else $fatal("FSM doesn't load dcard2 after pcard2");
    end
  endtask

  task automatic test_player_win();
    begin
      do_reset();
      // Step through state machine
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd9;
      dscore = 4'd8;
      @(posedge slow_clock);
      #1
      assert (player_win_light == 1 && dealer_win_light == 0)
      else $fatal("Player doesn't Win Game");
    end
  endtask

  task automatic test_dealer_win();
    begin
      do_reset();
      // Step through state machine
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd8;
      dscore = 4'd9;
      @(posedge slow_clock);
      #1
      assert (player_win_light == 0 && dealer_win_light == 1)
      else $fatal("Dealer doesn't Win Game");
    end
  endtask

  task automatic test_tie();
    begin
      do_reset();
      // Step through state machine
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd8;
      dscore = 4'd8;
      @(posedge slow_clock);
      #1
      assert (player_win_light == 1 && dealer_win_light == 1)
      else $fatal("Game Wasn't a Tie");
    end
  endtask

  task automatic test_natural();
    begin
      do_reset();
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd4;
      dscore = 4'd8;
      @(posedge slow_clock);
      #1
      assert(dealer_win_light == 1)
      else $fatal("Natural didn't occur");
    end 
  endtask

  task automatic test_player_draws_3rd_only();
    begin
      do_reset();
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd4;
      dscore = 4'd7;
      @(posedge slow_clock);
      #1
      assert(load_pcard3 == 1)
      else $fatal("Player Doesn't Draw Hand");
      
      @(posedge slow_clock);
      #1 
      assert(load_dcard3 == 0)
      else $fatal("Both Player and Dealer Draw");
    end 
  endtask

  task automatic test_dealer_draws_3rd_only();
    begin
      do_reset();
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd6;
      dscore = 4'd4;
      @(posedge slow_clock);
      #1
      assert(load_dcard3 == 1)
      else $fatal("Dealer Doesn't Draw Hand");
      
      @(posedge slow_clock);
      #1 
      assert(load_pcard3 == 0)
      else $fatal("Both Player and Dealer Draw");
    end 
  endtask

  task automatic test_both_dont_draw_3rd();
    begin
      do_reset();
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd6;
      dscore = 4'd7;
      @(posedge slow_clock);
      #1
      assert(load_dcard3 == 0)
      else $fatal("Dealer Draws Hand");
      
      @(posedge slow_clock);
      #1 
      assert(load_pcard3 == 0)
      else $fatal("Both Player and Dealer Draw");
    end 
  endtask

  task automatic test_both_draw_3rd();
    begin
      do_reset();
      @(posedge slow_clock);
      @(posedge slow_clock);
      @(posedge slow_clock);
      pscore = 4'd4;
      dscore = 4'd5;
      @(posedge slow_clock);
      #1
      assert(load_pcard3 == 1)
      else $fatal("Player Doesn't Draw Hand");
      
      pcard3 = 4'd4;
      @(posedge slow_clock);
      @(posedge slow_clock);
      #1 
      assert(load_dcard3 == 1)
      else $fatal("Dealer Doesn't Draw Hand");
    end 
  endtask

  initial begin
    test_reset();
    #10
    test_player_win();
    #10
    test_dealer_win();
    #10 
    test_tie();
    #10
    test_natural();
    #10 
    test_player_draws_3rd_only();
    #10 
    test_dealer_draws_3rd_only();
    #10
    test_both_dont_draw_3rd();
    #10 
    test_both_draw_3rd();
    
    $display("ALL TESTS PASSED");
    $finish;
  end

endmodule
