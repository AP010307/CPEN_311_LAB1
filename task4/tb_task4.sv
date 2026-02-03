`timescale 1ns/1ps

module tb_task4;

  logic slow_clock, resetb;
  logic [3:0] dscore, pscore, pcard3;

  logic load_pcard1, load_pcard2, load_pcard3;
  logic load_dcard1, load_dcard2, load_dcard3;
  logic player_win_light, dealer_win_light;

  // DUT
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

  // 10ns period clock
  initial slow_clock = 0;
  always #5 slow_clock = ~slow_clock;

  // Required watchdog
  initial begin
    #100000;
    $display("TIMEOUT: exceeded 100000 ticks");
    $finish;
  end

  always @(posedge slow_clock) begin
  #1ps;
  $display("%t p=%0d d=%0d lp1=%b ld1=%b lp2=%b ld2=%b lp3=%b ld3=%b",
           $time, pscore, dscore,
           load_pcard1, load_dcard1, load_pcard2, load_dcard2, load_pcard3, load_dcard3);
end


  task automatic do_reset;
    begin
      resetb = 0;
        @(posedge slow_clock);   // reset takes effect here
      resetb = 1;              // release
      #1ps;                    // let comb settle (no extra posedge)
    end
  endtask


  // // Wait N cycles max for a condition
  task automatic wait_cycles_or_fail(input int max_cycles, input string what);
    int i;
    begin
      for (i=0; i<max_cycles; i++) @(posedge slow_clock);
      #1ps;
      $display("FAIL: timed out waiting for %s", what);
      $finish;
    end
  endtask

  // Wait until either light is asserted (compare/result), but don’t hang
  task automatic wait_for_result;
  int i;
  begin
    for (i=0; i<50; i++) begin
      @(posedge slow_clock);
      #1ps;
      if (player_win_light || dealer_win_light) return;
    end
    $display("FAIL: never reached result lights within 50 cycles");
    $finish;
  end
endtask


  // Wait for a pulse on a load signal
task automatic wait_for_pulse(ref logic sig, input int max_cycles, input string name);
  int i;
  begin
    for (i=0; i<max_cycles; i++) begin
      @(posedge slow_clock);
      #1ps;
      if (sig) return;
    end
    $display("FAIL: never saw pulse on %s within %0d cycles", name, max_cycles);
    $finish;
  end
endtask


task automatic expect_pulse_within(ref logic sig, input int cycles, input string name);
  int i;
  begin
    for (i=0; i<cycles; i++) begin
      @(posedge slow_clock);
      #1ps;
      if (sig) begin
        $display("PASS: saw pulse on %s", name);
        return;
      end
    end
    $display("FAIL: expected pulse on %s within %0d cycles", name, cycles);
    $finish;
  end
endtask



  // Assert no pulse on a load signal for a window
task automatic expect_no_pulse(ref logic sig, input int cycles, input string name);
  int i;
  begin
    for (i=0; i<cycles; i++) begin
      @(posedge slow_clock);
      #1ps;
      if (sig) begin
        $display("FAIL: unexpected pulse on %s", name);
        $finish;
      end
    end
    $display("PASS: no pulse on %s for %0d cycles", name, cycles);
  end
endtask


  task automatic expect_result_within(input int cycles, input string tag);
  int i;
  begin
    for (i=0; i<cycles; i++) begin
      @(posedge slow_clock);
      #1ps;
      if (player_win_light || dealer_win_light) begin
        $display("PASS: result observed (%s)", tag);
        return;
      end
    end
    $display("FAIL: no result observed within %0d cycles (%s)", cycles, tag);
    $finish;
  end
endtask

task automatic wait_for_sequence_deal2;
  begin
    wait_for_pulse(load_pcard1, 50, "load_pcard1");
    wait_for_pulse(load_dcard1, 50, "load_dcard1");
    wait_for_pulse(load_pcard2, 50, "load_pcard2");
    wait_for_pulse(load_dcard2, 50, "load_dcard2");
  end
endtask

  // Check final lights
  task automatic check_lights(input bit expP, input bit expD, input string tag);
    begin
      if ((player_win_light!==expP) || (dealer_win_light!==expD)) begin
        $display("FAIL %s: got P=%0b D=%0b expected P=%0b D=%0b",
                 tag, player_win_light, dealer_win_light, expP, expD);
        $finish;
      end
      $display("PASS %s", tag);
    end
  endtask


  initial begin
    // init
    resetb = 1;
    pscore = 0; dscore = 0; pcard3 = 0;

    // -----------------------
    // 1) Natural dealer win: dealer=9 player=8
    // -----------------------
    pscore = 4'd8;
    dscore = 4'd9;
    pcard3 = 4'd0;
    do_reset();
    expect_result_within(50, "Natural dealer win (9>8)");
    check_lights(0, 1, "Natural dealer win (9>8)");

    // -----------------------
    // 2) Natural tie: dealer=8 player=8
    // -----------------------
    pscore = 4'd8;
    dscore = 4'd8;
    pcard3 = 4'd0;
    do_reset();
    expect_result_within(50, "Natural tie (8=8)");
    check_lights(1, 1, "Natural tie (8=8)");

    // -----------------------
    // 3) Natural Player win : dealer=8 player=9
    // -----------------------
    pscore = 4'd9;
    dscore = 4'd8;
    pcard3 = 4'd0;
    do_reset();
    expect_result_within(50, "Natural player win (9=8)");
    check_lights(1, 0, "Natural player win (9=8)");

//4) Player stands  (6/7), dealer draws if dealer 0..5
  pscore = 4'd0;
  dscore = 4'd0;
  pcard3 = 4'd0;

  do_reset();

  // sync to the end of dealing 2 cards each
  wait_for_sequence_deal2();

  // force eval condition
  pscore = 4'd7;   // stand
  dscore = 4'd5;   // dealer must draw
  pcard3 = 4'd0;

  // dealer draw should happen very soon (next ~1-3 cycles)
  expect_pulse_within(load_dcard3, 8, "load_dcard3 (dealer draws when player stands)");

    // -----------------------
    // 5) Player draws, dealer draws (banker rule)
    // Example: dscore=6 draws only if player third is 6/7
    // -----------------------
    pscore = 4'd2;   // player draws
    dscore = 4'd6;
    pcard3 = 4'd7;   // should cause dealer draw
    do_reset();

    wait_for_pulse(load_pcard3, 30, "load_pcard3 (player draws)");
    wait_for_pulse(load_dcard3, 50, "load_dcard3 (dealer draws by rule)");
    wait_for_result();
    $display("PASS Player draws -> dealer draws (d=6, p3=7)");

    // -----------------------
    // 6) Banker rule sweep (representative checks)
    // We only check whether dealer draws (load_dcard3) happens or not.
    // -----------------------

    // dscore 0/1/2: always draws if player drew
    pscore = 4'd0; dscore = 4'd2; pcard3 = 4'd1; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    wait_for_pulse(load_dcard3, 50, "dealer draws d=2 always");
    $display("PASS banker rule d=2 draws");

    // dscore 3: draws unless p3==8
    pscore = 4'd0; dscore = 4'd3; pcard3 = 4'd8; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    expect_no_pulse(load_dcard3, 10, "dealer stands d=3 when p3=8");
    $display("PASS banker rule d=3, p3=8 stands");

    pscore = 4'd0; dscore = 4'd3; pcard3 = 4'd7; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    wait_for_pulse(load_dcard3, 50, "dealer draws d=3 when p3!=8");
    $display("PASS banker rule d=3, p3=7 draws");

    // dscore 4: draws if p3 in 2..7
    pscore = 4'd0; dscore = 4'd4; pcard3 = 4'd1; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    expect_no_pulse(load_dcard3, 10, "dealer stands d=4 p3=1");
    $display("PASS banker rule d=4, p3=1 stands");

    pscore = 4'd0; dscore = 4'd4; pcard3 = 4'd6; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    wait_for_pulse(load_dcard3, 50, "dealer draws d=4 p3=6");
    $display("PASS banker rule d=4, p3=6 draws");

    // dscore 5: draws if p3 in 4..7
    pscore = 4'd0; dscore = 4'd5; pcard3 = 4'd3; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    expect_no_pulse(load_dcard3, 10, "dealer stands d=5 p3=3");
    $display("PASS banker rule d=5, p3=3 stands");

    pscore = 4'd0; dscore = 4'd5; pcard3 = 4'd4; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    wait_for_pulse(load_dcard3, 50, "dealer draws d=5 p3=4");
    $display("PASS banker rule d=5, p3=4 draws");

    // dscore 6: draws if p3 is 6 or 7
    pscore = 4'd0; dscore = 4'd6; pcard3 = 4'd5; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    expect_no_pulse(load_dcard3, 10, "dealer stands d=6 p3=5");
    $display("PASS banker rule d=6, p3=5 stands");

    pscore = 4'd0; dscore = 4'd6; pcard3 = 4'd6; do_reset();
    wait_for_pulse(load_pcard3, 30, "load_pcard3");
    wait_for_pulse(load_dcard3, 30, "dealer draws d=6 p3=6");
    $display("PASS banker rule d=6, p3=6 draws");

    $display("PASS: all requested hand cases tested under 100000 ticks");
    $finish;
  end

endmodule
