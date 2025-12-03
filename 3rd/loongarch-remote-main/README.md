<!--
 * @Author: BugNotFound
 * @Date: 2025-07-20 20:04:34
 * @LastEditTime: 2025-07-21 17:12:40
 * @FilePath: /loongson_remote/README.md
 * @Description: 
-->
# Loongson Remote

龙芯远程FPGA SoC构建及测试套件

## 使用

1.安装工具链

```bash
# 在根目录
cd ./sdk/toochains
./init.sh
```

在项目的根目录`source ./env.sh`，将工具链添加到环境变量中，**每次开启新终端都要执行该命令**。

2.安装vivado 2019.2 或 2023.2

3.初始化工程

```bash
# 在根目录
cd ./fpga
vivado -source create_project.tcl
```

注意根据vivado版本修改`create_project.tcl`中18行PLL IP的来源目录。

后续打开使用vivado时，直接打开`fpga/project_<时间>/Loongson_Soc.xpr`文件即可。


4.编译测试项目

```bash
# 在根目录
cd ./sdk/software/example/hello_world
make clean
make
```

可在`sdk/`和当前目录的`obj`下看到编译产物。其他的测试项目同理。

5.vivado 仿真。在vivado的ui中点击`SIMULATION`，然后点击`Run Simulation`，选择`Behavioral Simulation`。然后在仿真界面中点击`Run`按钮开始仿真。`hello_world`的仿真结果如下：

```text
run all
  Hello Loongarch32r!

a = 100

b = 3.256400

c = 5478.475630

String = ABCDE,  Address = 0x1c081000

this is src

run: Time (s): cpu = 00:00:51 ; elapsed = 00:00:45 . Memory (MB): peak = 8215.023 ; gain = 44.867 ; free physical = 59147 ; free virtual = 76341
```

仿真不会自动结束，需要手动点击`Break`按钮。

6.生成比特流文件。在vivado的ui中点击`PROGRAM AND DEBUG`，然后点击`Generate Bitstream`。生成的比特流文件在`fpga/project_<时间>/Loongson_Soc.runs/impl_1/`目录下，名为`soc_top.bit`。

7.在远程平台上运行测试程序。将`sdk`下的`bin`文件和比特流文件`soc_top.bit`上传到远程平台上。并观察运行效果。