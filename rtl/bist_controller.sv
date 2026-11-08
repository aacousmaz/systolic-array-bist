`timescale 1ns / 1ps

module bist_controller #(
    parameter int TEST_NUM = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic array_valid_out,

    output logic load_seed,
    output logic lfsr_enable,
    output logic array_start,
    output logic array_valid_in,
    output logic misr_clear,
    output logic misr_enable,
    output logic done,
    output logic [1:0] misr_word_sel
);

    typedef enum logic [3:0] {
        S_IDLE,
        S_INIT,
        S_START_ARRAY,
        S_WAIT_ARRAY,
        S_MISR_C00,
        S_MISR_C01,
        S_MISR_C10,
        S_MISR_C11,
        S_DONE
    } state_t;

    localparam int CNT_W = (TEST_NUM <= 1) ? 1 : $clog2(TEST_NUM + 1);

    state_t state;
    state_t next_state;
    logic [CNT_W-1:0] test_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            test_cnt <= '0;
        end else begin
            state <= next_state;

            if (state == S_INIT) begin
                test_cnt <= '0;
            end else if (state == S_MISR_C11) begin
                test_cnt <= test_cnt + 1'b1;
            end
        end
    end

    always_comb begin
        next_state = state;

        unique case (state)
            S_IDLE: begin
                if (start) begin
                    next_state = S_INIT;
                end
            end

            S_INIT: begin
                next_state = S_START_ARRAY;
            end

            S_START_ARRAY: begin
                next_state = S_WAIT_ARRAY;
            end

            S_WAIT_ARRAY: begin
                if (array_valid_out) begin
                    next_state = S_MISR_C00;
                end
            end

            S_MISR_C00: begin
                next_state = S_MISR_C01;
            end

            S_MISR_C01: begin
                next_state = S_MISR_C10;
            end

            S_MISR_C10: begin
                next_state = S_MISR_C11;
            end

            S_MISR_C11: begin
                if ((test_cnt + 1'b1) >= TEST_NUM) begin
                    next_state = S_DONE;
                end else begin
                    next_state = S_START_ARRAY;
                end
            end

            S_DONE: begin
                next_state = S_DONE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    always_comb begin
        load_seed      = 1'b0;
        lfsr_enable    = 1'b0;
        array_start    = 1'b0;
        array_valid_in = 1'b0;
        misr_clear     = 1'b0;
        misr_enable    = 1'b0;
        done           = 1'b0;
        misr_word_sel  = 2'd0;

        unique case (state)
            S_INIT: begin
                load_seed  = 1'b1;
                misr_clear = 1'b1;
            end

            S_START_ARRAY: begin
                lfsr_enable    = 1'b1;
                array_start    = 1'b1;
                array_valid_in = 1'b1;
            end

            S_MISR_C00: begin
                misr_word_sel = 2'd0;
                misr_enable   = 1'b1;
            end

            S_MISR_C01: begin
                misr_word_sel = 2'd1;
                misr_enable   = 1'b1;
            end

            S_MISR_C10: begin
                misr_word_sel = 2'd2;
                misr_enable   = 1'b1;
            end

            S_MISR_C11: begin
                misr_word_sel = 2'd3;
                misr_enable   = 1'b1;
            end

            S_DONE: begin
                done = 1'b1;
            end

            default: begin
            end
        endcase
    end

endmodule
