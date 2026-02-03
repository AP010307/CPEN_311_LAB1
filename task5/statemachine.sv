module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);


logic natural;
logic player_draw;
logic dealer_draw_if_player_draw;
logic dealer_draw_if_player_stand;
logic [3:0] player_third_card;


always_comb begin
  // Natural after two cards each
  natural = (pscore == 4'd8) || (pscore == 4'd9) ||
            (dscore == 4'd8) || (dscore == 4'd9);

  // Player draws if 0..5 and not natural
  player_draw = (!natural) && (pscore <= 4'd5);

  // Player stands case (pscore 6 or 7): dealer draws if 0..5
  dealer_draw_if_player_stand = (!natural) && (pscore >= 4'd6) && (dscore <= 4'd5);

  // Convert player's third card to baccarat value (A..9 => 1..9, else 0)
  player_third_card = (pcard3 >= 4'd1 && pcard3 <= 4'd9) ? pcard3 : 4'd0;

  // Dealer draw rule if player drew third card
  unique case (dscore)
    4'd0,4'd1,4'd2: dealer_draw_if_player_draw = 1'b1;
    4'd3:           dealer_draw_if_player_draw = (player_third_card != 4'd8);
    4'd4:           dealer_draw_if_player_draw = (player_third_card >= 4'd2 && player_third_card <= 4'd7);
    4'd5:           dealer_draw_if_player_draw = (player_third_card >= 4'd4 && player_third_card <= 4'd7);
    4'd6:           dealer_draw_if_player_draw = (player_third_card == 4'd6 || player_third_card == 4'd7);
    default:        dealer_draw_if_player_draw = 1'b0; // 7,8,9
  endcase
end


//FSM state transitions logic
typedef enum logic [3:0] {
  S0_DEAL_P1,   
  S1_DEAL_D1,
  S2_DEAL_P2,   
  S3_DEAL_D2,  
  S4_EVAL_2, 
  S5_DEAL_P3,
  S6_EVAL_D3,
  S7_DEAL_D3,
  S8_COMPARE
} state_t;



state_t state, next_state;

always_ff @(posedge slow_clock) begin
  if (!resetb)
    state <= S0_DEAL_P1;
  else
    state <= next_state;
end


always_comb begin
  // defaults
  load_pcard1 = 0; load_pcard2 = 0; load_pcard3 = 0;
  load_dcard1 = 0; load_dcard2 = 0; load_dcard3 = 0;
  player_win_light = 0; dealer_win_light = 0;
  next_state = state;

  unique case (state)

    S0_DEAL_P1: begin
      load_pcard1 = 1;
      next_state = S1_DEAL_D1;
    end

    S1_DEAL_D1: begin
      load_dcard1 = 1;
      next_state = S2_DEAL_P2;
    end

    S2_DEAL_P2: begin
      load_pcard2 = 1;
      next_state = S3_DEAL_D2;
    end

    S3_DEAL_D2: begin
      load_dcard2 = 1;
      next_state = S4_EVAL_2;
    end

    // After 2 cards each
    S4_EVAL_2: begin
      if (natural)
        next_state = S8_COMPARE;
      else if (player_draw)
        next_state = S5_DEAL_P3;
      else if (dealer_draw_if_player_stand)
        next_state = S7_DEAL_D3;
      else
        next_state = S8_COMPARE;
    end

    // Player third card
    S5_DEAL_P3: begin
      load_pcard3 = 1;
      next_state = S6_EVAL_D3;
    end

    // Dealer decision after player drew
    S6_EVAL_D3: begin
      if (dealer_draw_if_player_draw)
        next_state = S7_DEAL_D3;
      else
        next_state = S8_COMPARE;
    end

    // Dealer third card
    S7_DEAL_D3: begin
      load_dcard3 = 1;
      next_state = S8_COMPARE;
    end

    // Final result
    S8_COMPARE: begin
      if (pscore > dscore)
        player_win_light = 1;
      else if (dscore > pscore)
        dealer_win_light = 1;
      else begin
        player_win_light = 1;
        dealer_win_light = 1;
      end
      next_state = S0_DEAL_P1;
    end
    
    default: next_state = S0_DEAL_P1;
  endcase
end

endmodule