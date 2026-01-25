module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

logic [3:0] dealt_card;                

logic [3:0] PCard1;
logic [3:0] PCard2;
logic [3:0] PCard3;
logic [3:0] DCard1;
logic [3:0] DCard2;
logic [3:0] DCard3;

logic slow_clock_d;

card7seg PDisp1(.card(PCard1), .seg7(HEX0));
card7seg PDisp2(.card(PCard2), .seg7(HEX1));
card7seg PDisp3(.card(PCard3), .seg7(HEX2));

card7seg DDisp1(.card(DCard1), .seg7(HEX3));
card7seg DDisp2(.card(DCard2), .seg7(HEX4));
card7seg DDisp3(.card(DCard3), .seg7(HEX5));

dealcard(.clock(fast_clock), .resetb(resetb), .new_card(dealt_card));

always_ff @(posedge fast_clock) begin
  slow_clock_d <= slow_clock;

  if (resetb == 0) begin
    PCard1 <=4'b0000;
    PCard2 <=4'b0000;
    PCard3 <=4'b0000;
    
    DCard1 <=4'b0000;
    DCard2 <=4'b0000;
    DCard3 <=4'b0000;
  end
  else begin
    if (slow_clock_d == 1 && slow_clock == 0)
      PCard1 <= dealt_card;
  end
end

// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.
assign pcard3_out = PCard3;
endmodule

