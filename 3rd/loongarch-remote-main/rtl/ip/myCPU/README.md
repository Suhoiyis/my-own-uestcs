<!--
 * @Author: BugNotFound
 * @Date: 2025-07-05 16:10:06
 * @LastEditTime: 2025-07-08 16:37:06
 * @FilePath: /myCPU/README.md
 * @Description: 
-->
# openLA500
## 前言
openLA500是一款实现了龙芯架构32位精简版指令集（loongarch32r）的处理器核。其结构为单发射五级流水，分为取指、译码、执行、访存、写回五个流水级。并且含有两路组相连结构的指令和数据cache；32项tlb；以及简易的分支预测器。此外，处理器核对外为AXI接口，容易集成。

OpenLA500已经过流片验证，.13工艺下频率为100M，dhrystone，coremark分数分别为0.78 DMIPS/MHz(指令数有点高)，2.75 coremark/Mhz。软件方面，uboot、linux 5.14、ucore、rt-thread等常用工具及内核已完成对openLA500的适配。

详细设计报告见doc目录。

## 说明

本项目基于openLA500修改而来，用于LoongArch32精简指令集处理器设计教学目标，共设计4个lab，分别为：
- lab1：流水线设计（需通过chiplab：func/func_lab3-7）
- lab2：AXI总线/CSR设计/部分异常处理（需通过chiplab：func/func_lab8-12）
- lab3：Cache设计（需通过chiplab：coremark/drystone性能测试）
- lab4：MMU/TLB设计（原则上需通过chiplab所有测试，至少通过func/func_lab19、coremark、drystone、rtthread、linux）

每个lab需要实现的代码使用TODO(labx)标记。每个lab的代码均在对应的分支上（`dev-labx`），lab(x+1)会给出lab(x)的实现，lab4的实现位于`dev`分支。

chiplab func测试点列表：

```plaintext
n1_lu12i_w.S      n2_add_w.S        n3_addi_w.S       n4_sub_w.S        n5_slt.S
n6_sltu.S         n7_and.S          n8_or.S           n9_xor.S          n10_nor.S
n11_slli_w.S      n12_srli_w.S      n13_srai_w.S      n14_ld_w.S        n15_st_w.S
n16_beq.S         n17_bne.S         n18_bl.S          n19_jirl.S        n20_b.S
n21_pcaddu12i.S   n22_slti.S        n23_sltui.S       n24_andi.S        n25_ori.S
n26_xori.S        n27_sll_w.S       n28_sra_w.S       n29_srl_w.S       n30_div_w.S
n31_div_wu.S      n32_mul_w.S       n33_mulh_w.S      n34_mulh_wu.S     n35_mod_w.S
n36_mod_wu.S      n37_blt.S         n38_bge.S         n39_bltu.S        n40_bgeu.S
n41_ld_b.S        n42_ld_h.S        n43_ld_bu.S       n44_ld_hu.S       n45_st_b.S
n46_st_h.S        n47_syscall_ex.S  n48_brk_ex.S      n49_ti_ex.S       n50_ine_ex.S
n51_soft_int_ex.S n52_adef_ex.S     n53_ale_ld_w_ex.S n54_ale_ld_h_ex.S n55_ale_ld_hu_ex.S
n56_ale_st_h_ex.S n57_ale_st_w_ex.S n58_rdcnt.S       n59_tlbrd_tlbwr.S n60_tlbfill.S
n61_tlbsrch.S     n62_invtlb_0x0.S  n63_invtlb_0x1.S  n64_invtlb_0x2.S  n65_invtlb_0x3.S
n66_invtlb_0x4.S  n67_invtlb_0x5.S  n68_invtlb_0x6.S  n69_invtlb_inv_op.S n70_tlb_4MB.S
n71_tlb_ex.S      n72_dmw_test.S    n73_icacop_op0.S  n74_dcacop_op0.S  n75_icacop_op1.S
n76_dcacop_op1.S  n77_icacop_op2.S  n78_dcacop_op2.S  n79_cache_writeback.S n80_ti_ex_wait.S
n81_atomic_ins.S
```

chiplab func/func_lab测试点：
```plaintext
- lab3         : n1~n20
- lab4~5       : n1~n20
- lab6         : n1~n36
- lab7         : n1~n46
- lab8         : n1~n47
- lab9, 11~12  : n1~n58
- lab14        : n1~n70
- lab15, 17~18 : n1~n72
- lab19        : n1~n81
```

Tips:
- 实现过程中无需修改模块端口。
- 所有的题目用已有信号即可正确实现要求的功能。
- 如有必要也可声明新的中间变量。
