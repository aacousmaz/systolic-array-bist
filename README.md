# LFSR-MISR Built-In Self-Test for a 2x2 Systolic Array

## 1. Project Overview

This project implements a built-in self-test (BIST) system for a 2x2 systolic array in SystemVerilog. The design consists of a 16-bit LFSR test-pattern generator, a 2x2 MAC systolic array, a fault-injection module, a 16-bit MISR signature compactor, and a BIST controller.

The testbench instantiates both a fault-free top-level design and a top-level design with fault injection. Both instances use the same `SEED` and `TEST_NUM`. At the end of simulation, their final signatures are compared: they should match when no fault is injected and differ when a fault is injected.

## 2. Directory Structure

```text
rtl/
  lfsr_tpg.sv
  mac_pe.sv
  systolic_array_2x2.sv
  fault_injector.sv
  misr.sv
  bist_controller.sv
  bist_top.sv
sim/
  tb_bist_top.sv
README.md
```

## 3. Module Descriptions

- `lfsr_tpg.sv`: 16-bit LFSR test-pattern generator using the feedback polynomial `x^16 + x^14 + x^13 + x^11 + 1`.
- `mac_pe.sv`: A single processing element (PE)/MAC unit that computes `acc_out <= acc_out + a_in * b_in` and forwards the A/B data.
- `systolic_array_2x2.sv`: The 2x2 array under test. It instantiates four `mac_pe` units and performs matrix multiplication with two input cycles, K0 and K1.
- `fault_injector.sv`: 64-bit fault-injection module supporting bit-flip, stuck-at-0, and stuck-at-1 faults.
- `misr.sv`: 16-bit multiple-input signature register (MISR) that uses the same feedback polynomial as the LFSR.
- `bist_controller.sv`: BIST finite-state machine that controls LFSR loading, array start, MISR reset/enable, and the completion flag.
- `bist_top.sv`: Top-level module connecting the LFSR, systolic array, fault injector, MISR, and controller.
- `tb_bist_top.sv`: Testbench that runs fault-free operation and tests for the three fault types.

## 4. Running the Simulation in Vivado

1. Open the Vivado project `kechengsheji.xpr`.
2. Add `rtl/*.sv` to `sources_1`.
3. Add `sim/tb_bist_top.sv` to `sim_1`.
4. Set `tb_bist_top` as the simulation top.
5. Select **Run Simulation → Run Behavioral Simulation**.

Alternatively, run the following commands in the Tcl Console:

```tcl
add_files -fileset sources_1 [glob ./rtl/*.sv]
add_files -fileset sim_1 ./sim/tb_bist_top.sv
set_property top tb_bist_top [get_filesets sim_1]
launch_simulation
run all
```

## 5. Signals to Observe

- `tb_bist_top.sig_golden`
- `tb_bist_top.sig_faulty`
- `tb_bist_top.done_golden`
- `tb_bist_top.done_faulty`
- `tb_bist_top.fault_enable`
- `tb_bist_top.fault_mode`
- `tb_bist_top.fault_bit`
- `u_bist_golden.u_lfsr_tpg.lfsr_out`
- `u_bist_golden.u_systolic_array_2x2.c00/c01/c10/c11`
- `u_bist_faulty.u_fault_injector.data_out`

## 6. Expected Simulation Output

The simulation runs the following tests in sequence:

```text
========== 2x2 SYSTOLIC ARRAY BIST TEST START ==========
TEST_NUM = 16
SEED     = 16'hACE1

[Test 0: No Fault]
result = SIGNATURE MATCH, PASS

[Test 1: Bit Flip]
result = FAULT DETECTED, PASS

[Test 2: Stuck-at-0]
result = FAULT DETECTED, PASS

[Test 3: Stuck-at-1]
result = FAULT DETECTED, PASS

========== 2x2 SYSTOLIC ARRAY BIST TEST FINISHED ==========
OVERALL RESULT = PASS
```

The actual signature values depend on the LFSR sequence, array computation results, and MISR compaction process.

## 7. Design Notes

- Both RTL and testbench files use the `.sv` extension.
- Sequential logic uses `always_ff @(posedge clk or negedge rst_n)`.
- Combinational logic uses `always_comb`.
- The LFSR and MISR share the same feedback polynomial, which simplifies the course-design explanation.
- The BIST controller automatically sequences multiple tests, response compaction, and completion signaling.
- The testbench compares golden and faulty top-level instances to demonstrate fault detection.
