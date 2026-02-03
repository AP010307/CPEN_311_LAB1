`timescale 1ns/1ps

module tb_card7seg;

  reg  [3:0] SW;
  wire [6:0] HEX0;

  // DUT matches your module ports: (SW, HEX0)
  card7seg dut (
    .SW(SW),
    .HEX0(HEX0)
  );

  // Lab-style task: apply input, wait, print
  task automatic apply_and_show(input [3:0] val, input string name);
    begin
      SW = val;
      #10; // IMPORTANT: advance time so waveform shows it
      $display("SW=%b (%0d) %-6s -> HEX0=%b", SW, SW, name, HEX0);
    end
  endtask

  initial begin
    // start defined
    SW = 4'b0000;
    #1;

    // Step through all values so you see waveform change
    apply_and_show(4'd0,  "BLANK");
    apply_and_show(4'd1,  "A");
    apply_and_show(4'd2,  "2");
    apply_and_show(4'd3,  "3");
    apply_and_show(4'd4,  "4");
    apply_and_show(4'd5,  "5");
    apply_and_show(4'd6,  "6");
    apply_and_show(4'd7,  "7");
    apply_and_show(4'd8,  "8");
    apply_and_show(4'd9,  "9");
    apply_and_show(4'd10, "10->0");
    apply_and_show(4'd11, "J");
    apply_and_show(4'd12, "Q");
    apply_and_show(4'd13, "K");
    apply_and_show(4'd14, "INV");
    apply_and_show(4'd15, "INV");

    #50; // hold last value so you can inspect
    $stop;
  end

endmodule
