`timescale 1ns / 1ps

module tb_bist_top;

    localparam int TEST_NUM = 16;
    localparam logic [15:0] SEED = 16'hACE1;

    logic clk;
    logic rst_n;
    logic start;

    logic fault_enable;
    logic [1:0] fault_mode;
    logic [5:0] fault_bit;

    logic done_golden;
    logic done_faulty;
    logic [15:0] sig_golden;
    logic [15:0] sig_faulty;

    int error_count;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    bist_top #(
        .TEST_NUM (TEST_NUM),
        .SEED     (SEED)
    ) u_bist_golden (
        .clk             (clk),
        .rst_n           (rst_n),
        .start           (start),
        .fault_enable    (1'b0),
        .fault_mode      (2'b00),
        .fault_bit       (6'd0),
        .done            (done_golden),
        .final_signature (sig_golden)
    );

    bist_top #(
        .TEST_NUM (TEST_NUM),
        .SEED     (SEED)
    ) u_bist_faulty (
        .clk             (clk),
        .rst_n           (rst_n),
        .start           (start),
        .fault_enable    (fault_enable),
        .fault_mode      (fault_mode),
        .fault_bit       (fault_bit),
        .done            (done_faulty),
        .final_signature (sig_faulty)
    );

    task automatic reset_dut;
    begin
        rst_n = 1'b0;
        start = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (2) @(posedge clk);
    end
    endtask

    task automatic pulse_start;
    begin
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
    end
    endtask

    task automatic wait_done_or_timeout(output logic timeout);
        int wait_cycles;
    begin
        timeout = 1'b0;
        wait_cycles = 0;

        while (!(done_golden && done_faulty) && (wait_cycles < 1000)) begin
            @(posedge clk);
            wait_cycles++;
        end

        if (!(done_golden && done_faulty)) begin
            timeout = 1'b1;
        end
    end
    endtask

    task automatic run_one_test(
        input logic        f_en,
        input logic [1:0]  f_mode,
        input logic [5:0]  f_bit,
        input string       test_name
    );
        logic timeout;
    begin
        fault_enable = f_en;
        fault_mode   = f_mode;
        fault_bit    = f_bit;

        $display("");
        $display("[%s]", test_name);

        reset_dut();
        pulse_start();
        wait_done_or_timeout(timeout);
        #1;

        $display("golden_signature = 16'h%04h", sig_golden);
        $display("faulty_signature = 16'h%04h", sig_faulty);

        if (timeout) begin
            $display("result = TIMEOUT, FAIL");
            error_count++;
        end else if (!f_en) begin
            if (sig_golden == sig_faulty) begin
                $display("result = SIGNATURE MATCH, PASS");
            end else begin
                $display("result = SIGNATURE MISMATCH, FAIL");
                error_count++;
            end
        end else begin
            if (sig_golden != sig_faulty) begin
                $display("result = FAULT DETECTED, PASS");
            end else begin
                $display("result = FAULT NOT DETECTED, FAIL");
                error_count++;
            end
        end

        repeat (2) @(posedge clk);
    end
    endtask

    initial begin
        rst_n        = 1'b0;
        start        = 1'b0;
        fault_enable = 1'b0;
        fault_mode   = 2'b00;
        fault_bit    = 6'd0;
        error_count  = 0;

        $display("========== 2x2 SYSTOLIC ARRAY BIST TEST START ==========");
        $display("TEST_NUM = %0d", TEST_NUM);
        $display("SEED     = 16'h%04h", SEED);

        run_one_test(1'b0, 2'b00, 6'd0,  "Test 0: No Fault");
        run_one_test(1'b1, 2'b01, 6'd3,  "Test 1: Bit Flip");
        run_one_test(1'b1, 2'b10, 6'd23, "Test 2: Stuck-at-0");
        run_one_test(1'b1, 2'b11, 6'd45, "Test 3: Stuck-at-1");

        $display("");
        $display("========== 2x2 SYSTOLIC ARRAY BIST TEST FINISHED ==========");
        if (error_count == 0) begin
            $display("OVERALL RESULT = PASS");
        end else begin
            $display("OVERALL RESULT = FAIL, error_count = %0d", error_count);
        end

        #20;
        $finish;
    end

endmodule
