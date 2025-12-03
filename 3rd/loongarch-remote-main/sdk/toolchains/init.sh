#!/bin/bash
###
 # @Author: BugNotFound
 # @Date: 2025-07-20 20:04:34
 # @LastEditTime: 2025-07-20 20:07:59
 # @FilePath: /loongson_remote/sdk/toolchains/init.sh
 # @Description: 
### 

wget https://gitee.com/loongson-edu/la32r-toolchains/releases/download/v0.0.3/loongson-gnu-toolchain-8.3-x86_64-loongarch32r-linux-gnusf-v2.0.tar.xz
tar Jxvf loongson-gnu-toolchain-8.3-x86_64-loongarch32r-linux-gnusf-v2.0.tar.xz
mkdir picolibc
cd picolibc
wget https://gitee.com/ffshff/la32r-picolibc/releases/download/V1.0/picolibc.tar.gz
tar zxvf picolibc.tar.gz
cd ..
mkdir newlib
cd newlib
wget https://gitee.com/ffshff/newlib-la32r/releases/download/V1.0/newlib.tar.gz
tar zxvf newlib.tar.gz
cd ..
