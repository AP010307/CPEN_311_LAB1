`timescale 1ns/1ps

module tb_card7seg;

  logic [3:0] SW;
  logic [6:0] HEX0;

  // DUT
  card7seg dut (
    .SW(SW),
    .HEX0(HEX0)
  );

  // Expected patterns (active-low)
  localparam logic [6:0] BLANK = 7'b1111111;
  localparam logic [6:0] ACE   = 7'b0001000;
  localparam logic [6:0] TWO   = 7'b0100100;
  localparam logic [6:0] THREE = 7'b0110000;
  localparam logic [6:0] FOUR  = 7'b0011001;
  localparam logic [6:0] FIVE  = 7'b0010010;
  localparam logic [6:0] SIX   = 7'b0000010;
  localparam logic [6:0] SEVEN = 7'b1111000;
  localparam logic [6:0] EIGHT = 7'b0000000;
  localparam logic [6:0] NINE  = 7'b0010000;
  localparam logic [6:0] TEN0  = 7'b1000000; // "0" for card=10
  localparam logic [6:0] JACK  = 7'b1100001;
  localparam logic [6:0] QUEEN = 7'b0011000;
  localparam logic [6:0] KING  = 7'b0001001;

  // Helper: compute expected output
  function automatic logic [6:0] expected(input logic [3:0] v);
    unique case (v)
      4'd0:  expected = BLANK;
      4'd1:  expected = ACE;
      4'd2:  expected = TWO;
      4'd3:  expected = THREE;
      4'd4:  expected = FOUR;
      4'd5:  expected = FIVE;
      4'd6:  expected = SIX;
      4'd7:  expected = SEVEN;
      4'd8:  expected = EIGHT;
      4'd9:  expected = NINE;
      4'd10: expected = TEN0;
      4'd11: expected = JACK;
      4'd12: expected = QUEEN;
      4'd13: expected = KING;


      default: expected = BLANK; // 14,15 invalid => blank
    endcase
  endfunction

  // Apply + assert task
  task automatic apply_check(input logic [3:0] v);
    logic [6:0] exp;
    begin
      exp = expected(v);
      SW = v;
      #1; // allow comb logic to settle (short waveform)
      $display("SW=%0d (%b) -> HEX0=%b (exp=%b)", v, v, HEX0, exp);

      // assertion + exit on fail
      assert (HEX0 === exp)
      else begin
        $error("FAIL: SW=%0d expected HEX0=%b got %b", v, exp, HEX0);
        $finish;
      end
    end
  endtask

  initial begin
    SW = 4'd0;
    #1;

    // Test all 0..15
    for (int i = 0; i < 16; i++) begin
      apply_check(i[3:0]);
    end

    $display("PASS: card7seg all cases 0..15");
    $finish;
  end

endmodule
