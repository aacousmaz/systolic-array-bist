`timescale 1ns / 1ps

module fault_injector (
    input  logic [63:0] data_in,
    input  logic        fault_enable,
    input  logic [1:0]  fault_mode,
    input  logic [5:0]  fault_bit,
    output logic [63:0] data_out
);

    always_comb begin
        data_out = data_in;

        if (fault_enable) begin
            unique case (fault_mode)
                2'b00: data_out = data_in;
                2'b01: data_out[fault_bit] = ~data_in[fault_bit];
                2'b10: data_out[fault_bit] = 1'b0;
                2'b11: data_out[fault_bit] = 1'b1;
                default: data_out = data_in;
            endcase
        end
    end

endmodule
