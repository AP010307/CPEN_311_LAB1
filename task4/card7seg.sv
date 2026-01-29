module card7seg(input logic [3:0] card, output logic [6:0] seg7);
      // Active-low 7-seg patterns (a..g order depends on your board)
    typedef enum logic [6:0] {
        BLANK = 7'b1111111,
        TEN  =  7'b1000000,
        ACE   = 7'b0001000,
        TWO   = 7'b0100100,
        THREE = 7'b0110000,
        FOUR  = 7'b0011001,
        FIVE  = 7'b0010010,
        SIX   = 7'b0000010,
        SEVEN = 7'b1111000,
        EIGHT = 7'b0000000,
        NINE  = 7'b0010000,
        JACK  = 7'b1100001,
        QUEEN = 7'b0011000,
        KING  = 7'b0001001
    } seg_t;

    seg_t seg;  // internal "enum variable" holding the chosen pattern

    // Choose which symbolic pattern to show
    always_comb begin
        unique case (card)
      
            4'b0001:  seg = ACE;
            4'b0010:  seg = TWO;
            4'b0011:  seg = THREE;
            4'b0100:  seg = FOUR;
            4'b0101:  seg = FIVE;
            4'b0110:  seg = SIX;
            4'b0111:  seg = SEVEN;
            4'b1000:  seg = EIGHT;
            4'b1001:  seg = NINE;
            4'b1010:  seg = TEN;    // if your spec wants 10 -> 0
            4'b1011:  seg = JACK;
            4'b1100:  seg = QUEEN;
            4'b1101:  seg = KING;
            default:  seg = BLANK; // 0, 14, 15 -> blank
        endcase
    end

    // Drive the output
    always_comb begin
        seg7 = seg;
    end


endmodule

