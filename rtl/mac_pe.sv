`timescale 1ns / 1ps

module mac_pe (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        clear,
    input  logic        valid_in,
    input  logic [7:0]  a_in,
    input  logic [7:0]  b_in,
    output logic [7:0]  a_out,
    output logic [7:0]  b_out,
    output logic [15:0] acc_out,
    output logic        valid_out
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_out     <= 8'h00;
            b_out     <= 8'h00;
            acc_out   <= 16'h0000;
            valid_out <= 1'b0;
        end else begin
            a_out     <= a_in;
            b_out     <= b_in;
            valid_out <= valid_in;

            if (clear) begin
                acc_out <= 16'h0000;
            end else if (valid_in) begin
                acc_out <= acc_out + (a_in * b_in);
            end
        end
    end

endmodule
