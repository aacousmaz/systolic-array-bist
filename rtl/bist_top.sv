`timescale 1ns / 1ps

module bist_top #(
    parameter int TEST_NUM = 16,
    parameter logic [15:0] SEED = 16'hACE1
)(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,

    input  logic        fault_enable,
    input  logic [1:0]  fault_mode,
    input  logic [5:0]  fault_bit,

    output logic        done,
    output logic [15:0] final_signature
);

    logic        load_seed;
    logic        lfsr_enable;
    logic        array_start;
    logic        array_valid_in;
    logic        array_valid_out;
    logic        misr_clear;
    logic        misr_enable;
    logic [1:0]  misr_word_sel;

    logic [15:0] lfsr_out;

    logic [7:0] a00;
    logic [7:0] a01;
    logic [7:0] a10;
    logic [7:0] a11;
    logic [7:0] b00;
    logic [7:0] b01;
    logic [7:0] b10;
    logic [7:0] b11;

    logic [15:0] c00;
    logic [15:0] c01;
    logic [15:0] c10;
    logic [15:0] c11;
    logic [63:0] cut_out_64;
    logic [63:0] faulty_out_64;
    logic [15:0] misr_data_in;

    assign a00 = lfsr_out[7:0];
    assign a01 = lfsr_out[15:8];
    assign a10 = lfsr_out[11:4];
    assign a11 = {lfsr_out[3:0], lfsr_out[15:12]};

    assign b00 = lfsr_out[15:8];
    assign b01 = lfsr_out[7:0];
    assign b10 = {lfsr_out[5:0], lfsr_out[15:14]};
    assign b11 = {lfsr_out[9:0], lfsr_out[15:10]};

    assign cut_out_64 = {c11, c10, c01, c00};

    always_comb begin
        unique case (misr_word_sel)
            2'd0: misr_data_in = faulty_out_64[15:0];
            2'd1: misr_data_in = faulty_out_64[31:16];
            2'd2: misr_data_in = faulty_out_64[47:32];
            2'd3: misr_data_in = faulty_out_64[63:48];
            default: misr_data_in = 16'h0000;
        endcase
    end

    lfsr_tpg u_lfsr_tpg (
        .clk       (clk),
        .rst_n     (rst_n),
        .load_seed (load_seed),
        .enable    (lfsr_enable),
        .seed      (SEED),
        .lfsr_out  (lfsr_out)
    );

    systolic_array_2x2 u_systolic_array_2x2 (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (array_start),
        .valid_in  (array_valid_in),
        .a00       (a00),
        .a01       (a01),
        .a10       (a10),
        .a11       (a11),
        .b00       (b00),
        .b01       (b01),
        .b10       (b10),
        .b11       (b11),
        .c00       (c00),
        .c01       (c01),
        .c10       (c10),
        .c11       (c11),
        .valid_out (array_valid_out)
    );

    fault_injector u_fault_injector (
        .data_in      (cut_out_64),
        .fault_enable (fault_enable),
        .fault_mode   (fault_mode),
        .fault_bit    (fault_bit),
        .data_out     (faulty_out_64)
    );

    misr u_misr (
        .clk       (clk),
        .rst_n     (rst_n),
        .clear     (misr_clear),
        .enable    (misr_enable),
        .data_in   (misr_data_in),
        .signature (final_signature)
    );

    bist_controller #(
        .TEST_NUM (TEST_NUM)
    ) u_bist_controller (
        .clk             (clk),
        .rst_n           (rst_n),
        .start           (start),
        .array_valid_out (array_valid_out),
        .load_seed       (load_seed),
        .lfsr_enable     (lfsr_enable),
        .array_start     (array_start),
        .array_valid_in  (array_valid_in),
        .misr_clear      (misr_clear),
        .misr_enable     (misr_enable),
        .done            (done),
        .misr_word_sel   (misr_word_sel)
    );

endmodule
