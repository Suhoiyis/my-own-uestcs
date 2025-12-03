/**
 * TODO(lab1): LoongArch算术逻辑单元 (Arithmetic Logic Unit - ALU)
 * 提示：根据14位独热编码的ALU操作控制信号，执行各种算术和逻辑运算。
 */
module alu(
  input  [13:0] alu_op,     // ALU操作控制信号 (14位独热编码)
  input  [31:0] alu_src1,   // ALU第一个操作数 (通常是寄存器rj的值)
  input  [31:0] alu_src2,   // ALU第二个操作数 (可能是寄存器rk或立即数)
  output [31:0] alu_result  // ALU运算结果
);

/**
 * ALU操作控制信号分解
 * 使用独热编码，每一位对应一种ALU操作
 */
wire op_add;   // 加法运算
wire op_sub;   // 减法运算  
wire op_slt;   // 有符号数小于比较
wire op_sltu;  // 无符号数小于比较
wire op_and;   // 按位与运算
wire op_nor;   // 按位或非运算
wire op_or;    // 按位或运算
wire op_xor;   // 按位异或运算
wire op_sll;   // 逻辑左移
wire op_srl;   // 逻辑右移
wire op_sra;   // 算术右移
wire op_lui;   // 立即数加载到高位
wire op_andn;  // 按位与非运算 
wire op_orn;   // 按位或非运算 

// ALU操作控制码分解 (独热编码)
assign op_add  = alu_op[ 0];  // ADD, ADDI指令
assign op_sub  = alu_op[ 1];  // SUB指令
assign op_slt  = alu_op[ 2];  // SLT, SLTI指令
assign op_sltu = alu_op[ 3];  // SLTU, SLTUI指令
assign op_and  = alu_op[ 4];  // AND, ANDI指令
assign op_nor  = alu_op[ 5];  // NOR指令
assign op_or   = alu_op[ 6];  // OR, ORI指令
assign op_xor  = alu_op[ 7];  // XOR, XORI指令
assign op_sll  = alu_op[ 8];  // SLL, SLLI指令
assign op_srl  = alu_op[ 9];  // SRL, SRLI指令
assign op_sra  = alu_op[10];  // SRA, SRAI指令
assign op_lui  = alu_op[11];  // LU12I.W指令
assign op_andn = alu_op[12];  // ANDN指令
assign op_orn  = alu_op[13];  // ORN指令

/**
 * ALU各功能模块的中间结果信号
 */
wire [31:0] add_sub_result;  // 加法/减法运算结果
wire [31:0] slt_result;      // 有符号比较结果 (0或1)
wire [31:0] sltu_result;     // 无符号比较结果 (0或1)
wire [31:0] and_result;      // 按位与运算结果
wire [31:0] nor_result;      // 按位或非运算结果
wire [31:0] or_result;       // 按位或运算结果
wire [31:0] xor_result;      // 按位异或运算结果
wire [31:0] lui_result;      // 立即数加载结果
wire [31:0] sll_result;      // 逻辑左移结果
wire [63:0] sr64_result;     // 64位右移中间结果 (用于算术右移)
wire [31:0] sr_result;       // 右移运算结果
wire [31:0] andn_result;     // 按位与非运算结果
wire [31:0] orn_result;      // 按位或非运算结果


/**
 * 32位加法器模块
 * 用于执行加法、减法和比较运算的基础运算单元
 */
wire [31:0] adder_a;      // 加法器输入A
wire [31:0] adder_b;      // 加法器输入B  
wire        adder_cin;    // 加法器进位输入
wire [31:0] adder_result; // 加法器结果
wire        adder_cout;   // 加法器进位输出

assign adder_a   = alu_src1;  // 第一个操作数直接作为加法器输入A
// 对于减法和比较运算，将第二个操作数取反实现减法 (A - B = A + (~B) + 1)
assign adder_b   = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;
// 减法和比较运算时，进位输入为1以完成二进制补码减法
assign adder_cin = (op_sub | op_slt | op_sltu) ? 1'b1      : 1'b0;
// 执行加法运算：result = A + B + Cin
assign {adder_cout, adder_result} = adder_a + adder_b + adder_cin;

/**
 * 加法/减法运算结果
 * 直接使用加法器的输出结果
 */
assign add_sub_result = adder_result;

/**
 * 有符号数小于比较 (SLT)
 * 比较两个32位有符号数的大小关系
 * 结果为1表示src1 < src2，结果为0表示src1 >= src2
 */
assign slt_result[31:1] = 31'b0;  // 高31位恒为0
// 有符号比较逻辑：
// 1. 如果src1为负数且src2为正数，则src1 < src2
// 2. 如果两数符号相同，则比较减法结果的符号位
assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31])  // src1负，src2正
                        | ((alu_src1[31] ~^ alu_src2[31]) & adder_result[31]); // 同号且差值为负

/**
 * 无符号数小于比较 (SLTU)  
 * 比较两个32位无符号数的大小关系
 * 结果为1表示src1 < src2，结果为0表示src1 >= src2
 */
assign sltu_result[31:1] = 31'b0;  // 高31位恒为0
// 无符号比较：如果减法没有进位输出，说明发生了借位，即src1 < src2
assign sltu_result[0]    = ~adder_cout;

/**
 * 按位逻辑运算
 * 实现各种位级逻辑操作
 */
assign and_result = alu_src1 & alu_src2;   // 按位与：AND, ANDI指令
assign andn_result= alu_src1 & ~alu_src2;  // 按位与非：ANDN指令 
assign or_result  = alu_src1 | alu_src2;   // 按位或：OR, ORI指令  
assign orn_result = alu_src1 | ~alu_src2;  // 按位或非：ORN指令 
assign nor_result = ~or_result;            // 按位或非：NOR指令
assign xor_result = alu_src1 ^ alu_src2;   // 按位异或：XOR, XORI指令

/**
 * 立即数加载到高位 (LUI)
 * LU12I.W指令：将20位立即数加载到寄存器的高20位，低12位置0
 */
assign lui_result = alu_src2;  // src2已经是处理好的立即数值

/**
 * 逻辑左移运算 (SLL)
 * 将src1左移src2[4:0]位，空位补0
 * 移位数取src2的低5位，支持0-31位的移位
 */
assign sll_result = alu_src1 << alu_src2[4:0];

/**
 * 右移运算 (SRL/SRA)
 * 使用64位移位器同时实现逻辑右移和算术右移
 */
// 构造64位数据：对于算术右移，高32位用符号位填充；对于逻辑右移，高32位补0
assign sr64_result = {{32{op_sra & alu_src1[31]}}, alu_src1[31:0]} >> alu_src2[4:0];
// 取低32位作为最终的右移结果
assign sr_result   = sr64_result[31:0];

/**
 * ALU最终结果选择器
 * 根据操作控制信号选择相应的运算结果
 * 使用独热编码进行结果选择，确保同时只有一个运算结果被选中
 */
assign alu_result = ({32{op_add|op_sub}} & add_sub_result)    // 加法/减法结果
                  | ({32{op_slt       }} & slt_result)        // 有符号比较结果
                  | ({32{op_sltu      }} & sltu_result)       // 无符号比较结果
                  | ({32{op_and       }} & and_result)        // 按位与结果
                  | ({32{op_andn      }} & andn_result)       // 按位与非结果
                  | ({32{op_nor       }} & nor_result)        // 按位或非结果
                  | ({32{op_or        }} & or_result)         // 按位或结果
                  | ({32{op_orn       }} & orn_result)        // 按位或非结果
                  | ({32{op_xor       }} & xor_result)        // 按位异或结果
                  | ({32{op_lui       }} & lui_result)        // 立即数加载结果
                  | ({32{op_sll       }} & sll_result)        // 逻辑左移结果
                  | ({32{op_srl|op_sra}} & sr_result);        // 右移结果(逻辑/算术)

endmodule
