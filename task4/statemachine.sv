module statemachine(input logic slow_clock, input logic resetb,
                    input logic [3:0] dscore, input logic [3:0] pscore, input logic [3:0] pcard3,
                    output logic load_pcard1, output logic load_pcard2, output logic load_pcard3,
                    output logic load_dcard1, output logic load_dcard2, output logic load_dcard3,
                    output logic player_win_light, output logic dealer_win_light);

// The code describing your state machine will go here.  Remember that
// a state machine consists of next state logic, output logic, and the 
// registers that hold the state.  You will want to review your notes from
// CPEN 211 or equivalent if you have forgotten how to write a state machine.

//FSM state transitions logic
typedef enum logic [2:0] {
    S0_IDLE,
    S1_DEAL_P1,
    S2_DEAL_D1,
    S3_DEAL_P2,
    S4_DEAL_D2,
    S5_DEAL_P3,
    S6_DEAL_D3,
    S7_COMPARE
} state_t;

state_t state, next_state;

always_ff @(posedge slow_clock) begin
    if (!resetb)
        state <= S0_IDLE;
    else
        state <= next_state;
end

always_comb begin
    // Default outputs
    load_pcard1 = 0;
    load_pcard2 = 0;
    load_pcard3 = 0;
    load_dcard1 = 0;
    load_dcard2 = 0;
    load_dcard3 = 0;
    player_win_light = 0;
    dealer_win_light = 0;

    // Next state logic
    unique case (state)
        S0_IDLE: begin
            load_pcard1 = 1;
            next_state = S1_DEAL_P1;
        end
        S1_DEAL_P1: begin
            load_dcard1 = 1;
            next_state = S2_DEAL_D1;
        end
        S2_DEAL_D1: begin
            load_pcard2 = 1;
            next_state = S3_DEAL_P2;
        end
        S3_DEAL_P2: begin
            load_dcard2 = 1;
            next_state = S4_DEAL_D2;
        end
        S4_DEAL_D2: begin
            load_pcard3 = 1;
            next_state = S5_DEAL_P3;
        end
        S5_DEAL_P3: begin
            load_dcard3 = 1;
            next_state = S6_DEAL_D3;
        end
        S6_DEAL_D3: begin
            next_state = S7_COMPARE;
        end
        S7_COMPARE: begin
            if (pscore > dscore) 
                player_win_light = 1;
        
            else if (dscore > pscore)
                dealer_win_light = 1;
            else begin
                //both lights on for tie
                player_win_light = 1;
                dealer_win_light = 1;
            end
            next_state = S0_IDLE;
        end
        default: begin
            next_state = S0_IDLE;
        end
    endcase

end

endmodule

