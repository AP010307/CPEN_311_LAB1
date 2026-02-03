module datapath(input logic slow_clock, input logic fast_clock, input logic resetb,
                input logic load_pcard1, input logic load_pcard2, input logic load_pcard3,
                input logic load_dcard1, input logic load_dcard2, input logic load_dcard3,
                output logic [3:0] pcard3_out,
                output logic [3:0] pscore_out, output logic [3:0] dscore_out,
                output logic [6:0] HEX5, output logic [6:0] HEX4, output logic [6:0] HEX3,
                output logic [6:0] HEX2, output logic [6:0] HEX1, output logic [6:0] HEX0);

// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.
logic [3:0] PCard1, PCard2, PCard3, DCard1, DCard2, DCard3;

logic [3:0] new_card;


// Instantiate dealcard block
dealcard dc (.clock(fast_clock), .resetb(resetb), .new_card(new_card));
// Instantiate scorehand blocks
scorehand pscore (.card1(PCard1), .card2(PCard2), .card3(PCard3), .total(pscore_out));
scorehand dscore (.card1(DCard1), .card2(DCard2), .card3(DCard3), .total(dscore_out));
// Instantiate card7seg blocks
card7seg segPCard1 (.card(PCard1), .seg7(HEX0));
card7seg segPCard2 (.card(PCard2), .seg7(HEX1));
card7seg segPCard3 (.card(PCard3), .seg7(HEX2));
card7seg segDCard1 (.card(DCard1), .seg7(HEX3));
card7seg segDCard2 (.card(DCard2), .seg7(HEX4));
card7seg segDCard3 (.card(DCard3), .seg7(HEX5));

// Output the third player card
assign pcard3_out = PCard3;


// Sequential logic to load player and dealer cards
always_ff @(posedge slow_clock) begin
  if (!resetb) begin
    PCard1 <= 0; PCard2 <= 0; PCard3 <= 0;
    DCard1 <= 0; DCard2 <= 0; DCard3 <= 0;
  end
  else if (load_pcard1) begin
    // Start of a new game: clear everything, then deal P1
    PCard1 <= new_card;
    PCard2 <= 0; PCard3 <= 0;
    DCard1 <= 0; DCard2 <= 0; DCard3 <= 0;
  end
  else begin
    if (load_pcard2) PCard2 <= new_card;
    if (load_pcard3) PCard3 <= new_card;
    if (load_dcard1) DCard1 <= new_card;
    if (load_dcard2) DCard2 <= new_card;
    if (load_dcard3) DCard3 <= new_card;
  end
end



endmodule

