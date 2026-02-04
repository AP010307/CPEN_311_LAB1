module scorehand(input logic [3:0] card1, input logic [3:0] card2, input logic [3:0] card3, output logic [3:0] total);

// The code describing scorehand will go here.  Remember this is a combinational
// block. The function is described in the handout. Be sure to review Verilog
// notes on bitwidth mismatches and signed/unsigned numbers.

function automatic logic [3:0] card_value(input logic [3:0] card);
    begin 
        if (card>=4'd1 && card<=4'd9 )
            card_value = card;
        else
            card_value = 4'd0;
    end

endfunction

always_comb begin
    logic [5:0] sum;

    sum = card_value(card1) + card_value(card2) + card_value(card3);    
    total = sum % 10;

end


endmodule


