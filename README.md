# 面向 2x2 脉动阵列的 LFSR-MISR 内建自测试系统设计

## 1. 工程简介

本工程使用 SystemVerilog 实现一个面向 2x2 脉动阵列的 BIST 系统。系统由 16 位 LFSR 测试向量发生器、2x2 MAC 脉动阵列、故障注入模块、16 位 MISR 签名压缩器和 BIST 控制器组成。

testbench 同时实例化无故障顶层和带故障注入顶层，二者使用相同的 `SEED` 和 `TEST_NUM`。仿真结束后比较两个最终签名：无故障时应匹配，注入故障时应不匹配。

## 2. 文件结构

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

## 3. 各模块功能

- `lfsr_tpg.sv`：16 位 LFSR 测试向量发生器，反馈多项式为 `x^16 + x^14 + x^13 + x^11 + 1`。
- `mac_pe.sv`：单个 PE/MAC 单元，完成 `acc_out <= acc_out + a_in * b_in`，并传递 A/B 数据。
- `systolic_array_2x2.sv`：2x2 待测阵列，内部例化 4 个 `mac_pe`，按 K0、K1 两轮输入完成矩阵乘法。
- `fault_injector.sv`：64 位故障注入模块，支持 bit 翻转、stuck-at-0 和 stuck-at-1。
- `misr.sv`：16 位 MISR 响应压缩器，使用与 LFSR 相同的反馈多项式。
- `bist_controller.sv`：BIST 控制状态机，负责 LFSR 加载、阵列启动、MISR 清零/使能和完成标志。
- `bist_top.sv`：顶层模块，连接 LFSR、脉动阵列、故障注入器、MISR 和控制器。
- `tb_bist_top.sv`：仿真平台，运行无故障和三种故障注入测试。

## 4. Vivado 仿真步骤

1. 打开 Vivado 工程 `kechengsheji.xpr`。
2. 将 `rtl/*.sv` 添加到 `sources_1`。
3. 将 `sim/tb_bist_top.sv` 添加到 `sim_1`。
4. 设置仿真顶层为 `tb_bist_top`。
5. 点击 `Run Simulation -> Run Behavioral Simulation`。

也可以在 Tcl Console 中执行：

```tcl
add_files -fileset sources_1 [glob ./rtl/*.sv]
add_files -fileset sim_1 ./sim/tb_bist_top.sv
set_property top tb_bist_top [get_filesets sim_1]
launch_simulation
run all
```

## 5. 主要观察信号

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

## 6. 预期仿真结果

仿真会依次执行以下测试：

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

实际签名值会由 LFSR 序列、阵列计算结果和 MISR 压缩过程共同决定。

## 7. 设计特点

- RTL 和 testbench 均使用 `.sv` 文件。
- 时序逻辑统一使用 `always_ff @(posedge clk or negedge rst_n)`。
- 组合逻辑统一使用 `always_comb`。
- LFSR、MISR 使用相同反馈多项式，便于课程设计说明。
- BIST 控制器自动完成多轮测试、响应压缩和完成指示。
- testbench 同时比较 golden 和 faulty 两个顶层实例，直观展示故障检测效果。
