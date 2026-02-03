module tb_scorehand();

// Your testbench goes here. Make sure your tests exercise the entire design
// in the .sv file.  Note that in our tests the simulator will exit after
// 10,000 ticks (equivalent to "initial #10000 $finish();").
  
  logic slow_clock;
  logic [5:0] score_out;
  logic [3:0] Card1, Card2, Card3;

  scorehand score(.card1(Card1), .card2(Card2), .card3(Card3), .total(score_out));

  initial #10000 $finish();

  initial slow_clock = 0;
  always #5 slow_clock = ~slow_clock;
  
  initial begin
    // Test Sum < 10
    Card1 = 4'd1;
    Card2 = 4'd1;
    Card3 = 4'd1;
    
    assert (score_out == 4'd3)
    else $fatal("ASSERT FAIL: score_out != 4 at time %0t", $time);

    #10
    // Test Sum > 10
    Card1 = 4'd4;
    Card2 = 4'd5;
    Card3 = 4'd6;

    assert(score_out == 4'd5)
    else $fatal("ASSERT FAIL: score_out != 5 at time %0t", $time);

    #10
    // Test Sum of Cards Including Those Equal to Zero
    Card1 = 4'd11; // Jack (Score of Zero)
    Card2 = 4'd5;  // Normal Card
    Card3 = 4'd6;  // Normal Card

    assert(score_out == 4'd1)
    else $fatal("ASSERT FAIL: score_out = %1t != 1 at time %0t", $time, $score_out);

    $display("All Tests Passed");
  end
  
endmodule
