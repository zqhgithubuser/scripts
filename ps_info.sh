#!/bin/bash

read -p "请输入进程名称: " process_name

# 查找进程 ID
pids=$(pgrep -x "$process_name")

# 判断进程是否存在
if [[ -z "$pids" ]]; then
    echo "未找到进程 '$process_name'"
    exit 1
fi

# 输出进程信息
echo "进程 '$process_name' 详细信息:"
ps -o user,pid,%cpu,%mem,vsz,rss,stat,cmd -p $pids
