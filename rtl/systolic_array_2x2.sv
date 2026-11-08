`timescale 1ns / 1ps

module systolic_array_2x2 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic        valid_in,

    input  logic [7:0]  a00,
    input  logic [7:0]  a01,
    input  logic [7:0]  a10,
    input  logic [7:0]  a11,

    input  logic [7:0]  b00,
    input  logic [7:0]  b01,
    input  logic [7:0]  b10,
    input  logic [7:0]  b11,

    output logic [15:0] c00,
    output logic [15:0] c01,
    output logic [15:0] c10,
    output logic [15:0] c11,
    output logic        valid_out
);

    typedef enum logic [1:0] {
        S_IDLE,
        S_K0,
        S_K1,
        S_OUT
    } state_t;

    state_t state;
    state_t next_state;

    logic        pe_clear;
    logic        pe_valid;
    logic [7:0]  pe00_a;
    logic [7:0]  pe01_a;
    logic [7:0]  pe10_a;
    logic [7:0]  pe11_a;
    logic [7:0]  pe00_b;
    logic [7:0]  pe01_b;
    logic [7:0]  pe10_b;
    logic [7:0]  pe11_b;

    logic [7:0]  pe00_a_out;
    logic [7:0]  pe01_a_out;
    logic [7:0]  pe10_a_out;
    logic [7:0]  pe11_a_out;
    logic [7:0]  pe00_b_out;
    logic [7:0]  pe01_b_out;
    logic [7:0]  pe10_b_out;
    logic [7:0]  pe11_b_out;
    logic [15:0] pe00_acc;
    logic [15:0] pe01_acc;
    logic [15:0] pe10_acc;
    logic [15:0] pe11_acc;
    logic        pe00_valid_out;
    logic        pe01_valid_out;
    logic        pe10_valid_out;
    logic        pe11_valid_out;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;

        unique case (state)
            S_IDLE: begin
                if (start && valid_in) begin
                    next_state = S_K0;
                end
            end

            S_K0: begin
                next_state = S_K1;
            end

            S_K1: begin
                next_state = S_OUT;
            end

            S_OUT: begin
                next_state = S_IDLE;
            end

            default: begin
                next_state = S_IDLE;
            end
        endcase
    end

    always_comb begin
        pe_clear = 1'b0;
        pe_valid = 1'b0;

        pe00_a = 8'h00;
        pe01_a = 8'h00;
        pe10_a = 8'h00;
        pe11_a = 8'h00;
        pe00_b = 8'h00;
        pe01_b = 8'h00;
        pe10_b = 8'h00;
        pe11_b = 8'h00;

        unique case (state)
            S_IDLE: begin
                if (start && valid_in) begin
                    pe_clear = 1'b1;
                end
            end

            S_K0: begin
                pe_valid = 1'b1;
                pe00_a   = a00;
                pe01_a   = a00;
                pe10_a   = a10;
                pe11_a   = a10;
                pe00_b   = b00;
                pe01_b   = b01;
                pe10_b   = b00;
                pe11_b   = b01;
            end

            S_K1: begin
                pe_valid = 1'b1;
                pe00_a   = a01;
                pe01_a   = a01;
                pe10_a   = a11;
                pe11_a   = a11;
                pe00_b   = b10;
                pe01_b   = b11;
                pe10_b   = b10;
                pe11_b   = b11;
            end

            default: begin
            end
        endcase
    end

    always_comb begin
        c00       = pe00_acc;
        c01       = pe01_acc;
        c10       = pe10_acc;
        c11       = pe11_acc;
        valid_out = (state == S_OUT);
    end

    mac_pe u_pe00 (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear     (pe_clear),
        .valid_in  (pe_valid),
        .a_in      (pe00_a),
        .b_in      (pe00_b),
        .a_out     (pe00_a_out),
        .b_out     (pe00_b_out),
        .acc_out   (pe00_acc),
        .valid_out (pe00_valid_out)
    );

    mac_pe u_pe01 (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear     (pe_clear),
        .valid_in  (pe_valid),
        .a_in      (pe01_a),
        .b_in      (pe01_b),
        .a_out     (pe01_a_out),
        .b_out     (pe01_b_out),
        .acc_out   (pe01_acc),
        .valid_out (pe01_valid_out)
    );

    mac_pe u_pe10 (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear     (pe_clear),
        .valid_in  (pe_valid),
        .a_in      (pe10_a),
        .b_in      (pe10_b),
        .a_out     (pe10_a_out),
        .b_out     (pe10_b_out),
        .acc_out   (pe10_acc),
        .valid_out (pe10_valid_out)
    );

    mac_pe u_pe11 (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear     (pe_clear),
        .valid_in  (pe_valid),
        .a_in      (pe11_a),
        .b_in      (pe11_b),
        .a_out     (pe11_a_out),
        .b_out     (pe11_b_out),
        .acc_out   (pe11_acc),
        .valid_out (pe11_valid_out)
    );

endmodule
