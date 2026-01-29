`timescale 1ns/1ps

module tb_card7seg;

  logic [3:0] card;
  logic [6:0] seg7;

  // DUT
  card7seg dut (
    .card(card),
    .seg7(seg7)
  );

  // task to apply input and wait
  task check(input [3:0] c);
    begin
      card = c;
      #1;
      $display("card=%0d seg7=%b", card, seg7);
    end
  endtask

  initial begin
    $display("=== card7seg test ===");

    check(4'd0);   // blank
    check(4'd1);   // A
    check(4'd2);
    check(4'd3);
    check(4'd4);
    check(4'd5);
    check(4'd6);
    check(4'd7);
    check(4'd8);
    check(4'd9);
    check(4'd10);  // 0
    check(4'd11);  // J
    check(4'd12);  // Q
    check(4'd13);  // K
    check(4'd14);  // blank
    check(4'd15);  // blank

    $display("=== card7seg test DONE ===");
    $finish;
  end

endmodule
