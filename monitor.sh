#!/bin/bash

# 设置颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 定义监控函数
monitor_cpu() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo -e "${BLUE}CPU 使用率: $cpu_usage%${NC}"
    if (( $(echo "$cpu_usage > 80" | bc -l) )); then
        echo -e "${RED}警告: CPU 使用率过高!${NC}"
    fi
}

monitor_memory() {
    mem_total=$(free -m | awk '/Mem:/ {print $2}')
    mem_used=$(free -m | awk '/Mem:/ {print $3}')
    mem_usage=$((mem_used * 100 / mem_total))
    echo -e "${BLUE}内存使用率: $mem_usage%${NC}"
    if (( $mem_usage > 80 )); then
        echo -e "${RED}警告: 内存使用率过高!${NC}"
    fi
}

monitor_disk() {
    disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//g')
    echo -e "${BLUE}根分区使用率: $disk_usage%${NC}"
    if (( $disk_usage > 80 )); then
        echo -e "${RED}警告: 磁盘使用率过高!${NC}"
    fi
}

monitor_processes() {
    process_count=$(ps aux | wc -l)
    echo -e "${BLUE}进程数量: $process_count${NC}"
    if (( $process_count > 500 )); then
        echo -e "${RED}警告: 进程数量过多!${NC}"
    fi
}

# 主程序
while true; do
    clear
    echo -e "${GREEN}服务器监控${NC}"
    monitor_cpu
    monitor_memory
    monitor_disk
    monitor_processes
    sleep 5
done