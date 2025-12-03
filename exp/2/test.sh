#!/bin/bash

# 1. 清屏
clear

# 2. 提示用户输入要检测其状态的文件名
echo "Input file name:"
read FILENAME

# 3. 显示该文件的状态信息，或找不到该文件时的错误提示。
# 如果不存在，显示错误并退出。
if [ ! -f "$FILENAME" ] 
	then
    echo "Can't find the file [$FILENAME]"
    exit 1
fi

# 如果文件存在，显示其初始状态信息。
if [ -f "$FILENAME" ] 
	then
    echo "Current status of [$FILENAME] is:"
    ls -l "$FILENAME"
fi

# 4. 用cut命令，或用sed或awk命令来截取状态信息中文件的大小并保存
# 'awk' 命令打印第5个字段（即文件大小）。
LAST_SIZE=$(ls -l "$FILENAME" | awk '{print $5}')

# 初始化变更计数器和未变更计数器。
CHANGE_COUNT=0
NO_CHANGE_COUNT=0

echo "test file's status ..."

# 5.每隔5秒钟检测一次该文件大小的信息，并与保存的文件原来的大小相比较；
while true
	do
    # 每隔5秒。
    sleep 5

    # 获取当前的文件大小。
    CURRENT_SIZE=$(ls -l "$FILENAME" | awk '{print $5}')

    # 将当前大小与上次记录的大小进行比较。
    if [ "$CURRENT_SIZE" -ne "$LAST_SIZE" ] 
		then
        # 7. 如果文件大小已改变，则保存新的文件大小，并在屏幕上显示：
		#  		file [ filename ] size changed
		# （括号中的filename为本程序运行时用户输入的被检测的文件名）。程序继续每隔5秒钟检测一次文件的大小

        echo "file [$FILENAME] size changed!"
        LAST_SIZE=$CURRENT_SIZE
        CHANGE_COUNT=$((CHANGE_COUNT + 1))
		
        # 文件大小变更，重置未变更计数器。
        NO_CHANGE_COUNT=0
    else
        # 6. 如果文件大小未改变，则屏幕显示不变，并继续每隔5秒钟检测一次
        NO_CHANGE_COUNT=$((NO_CHANGE_COUNT + 1))
        echo "test file's status ..."
    fi

    # 8. 程序循环执行5~7步的操作。当被检测的文件或者已累计改变了两次大小，或者已连续被检测了十次还未改变大小时，给出相应提示，然后清屏退出
	
    # 如果文件大小改变了两次，则退出
    if [ "$CHANGE_COUNT" -ge 2 ] 
		then
        echo "Change number exceed two, test end!"
        break
    fi

    # 如果文件连续检查十次大小都未改变，则退出
    if [ "$NO_CHANGE_COUNT" -ge 10 ] 
		then
        echo "test number exceed ten!"
        break
    fi
done

sleep 5
# 清除屏幕并退出程序。
clear
exit 0