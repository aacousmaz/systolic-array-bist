`timescale 1ns / 1ps

module misr (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        clear,
    input  logic        enable,
    input  logic [15:0] data_in,
    output logic [15:0] signature
);

    logic feedback;
    logic [15:0] sig_next;

    assign feedback = signature[15] ^ data_in[0];

    always_comb begin
        sig_next = '0;

        sig_next[0]  = feedback;
        sig_next[1]  = signature[0]  ^ data_in[1];
        sig_next[2]  = signature[1]  ^ data_in[2];
        sig_next[3]  = signature[2]  ^ data_in[3];
        sig_next[4]  = signature[3]  ^ data_in[4];
        sig_next[5]  = signature[4]  ^ feedback ^ data_in[5];
        sig_next[6]  = signature[5]  ^ data_in[6];
        sig_next[7]  = signature[6]  ^ data_in[7];
        sig_next[8]  = signature[7]  ^ data_in[8];
        sig_next[9]  = signature[8]  ^ data_in[9];
        sig_next[10] = signature[9]  ^ data_in[10];
        sig_next[11] = signature[10] ^ feedback ^ data_in[11];
        sig_next[12] = signature[11] ^ data_in[12];
        sig_next[13] = signature[12] ^ feedback ^ data_in[13];
        sig_next[14] = signature[13] ^ feedback ^ data_in[14];
        sig_next[15] = signature[14] ^ data_in[15];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            signature <= 16'h0000;
        end else if (clear) begin
            signature <= 16'h0000;
        end else if (enable) begin
            signature <= sig_next;
        end
    end

endmodule
