#!/bin/bash

# 颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker 未安装,请先安装 Docker!${NC}"
    exit 1
fi

# 函数定义
install_mysql() {
    read -p "请输入 MySQL 密码 (留空将使用默认密码 'root'): " mysql_password
    mysql_password=${mysql_password:-root}

    echo -e "${BLUE}请选择 MySQL 版本:${NC}"
    echo "1) MySQL 5.7"
    echo "2) MySQL 8.0"
    read -p "输入选项: " mysql_version

    case $mysql_version in
        1)
            echo -e "${BLUE}正在安装 MySQL 5.7...${NC}"
            docker run -d --name mysql57 -p 3306:3306 -e MYSQL_ROOT_PASSWORD="$mysql_password" mysql:5.7
            echo -e "${GREEN}MySQL 5.7 安装完成!${NC}"
            ;;
        2)
            echo -e "${BLUE}正在安装 MySQL 8.0...${NC}"
            docker run -d --name mysql80 -p 3307:3306 -e MYSQL_ROOT_PASSWORD="$mysql_password" mysql:8.0
            echo -e "${GREEN}MySQL 8.0 安装完成!${NC}"
            ;;
        *) echo -e "${RED}无效选项,请重试!${NC}"; install_mysql ;;
    esac
}

uninstall_mysql() {
    echo -e "${BLUE}请选择要卸载的 MySQL 版本:${NC}"
    echo "1) MySQL 5.7"
    echo "2) MySQL 8.0"
    read -p "输入选项: " mysql_version

    case $mysql_version in
        1)
            echo -e "${BLUE}正在卸载 MySQL 5.7...${NC}"
            docker stop mysql57 && docker rm mysql57
            echo -e "${GREEN}MySQL 5.7 已卸载!${NC}"
            ;;
        2)
            echo -e "${BLUE}正在卸载 MySQL 8.0...${NC}"
            docker stop mysql80 && docker rm mysql80
            echo -e "${GREEN}MySQL 8.0 已卸载!${NC}"
            ;;
        *) echo -e "${RED}无效选项,请重试!${NC}"; uninstall_mysql ;;
    esac
}

install_redis() {
    echo -e "${BLUE}正在安装 Redis...${NC}"
    docker run -d --name redis -p 6379:6379 redis
    echo -e "${GREEN}Redis 安装完成!${NC}"
}

uninstall_redis() {
    echo -e "${BLUE}正在卸载 Redis...${NC}"
    docker stop redis && docker rm redis
    echo -e "${GREEN}Redis 已卸载!${NC}"
}

install_mongo() {
    echo -e "${BLUE}正在安装 MongoDB...${NC}"
    docker run -d --name mongo -p 27017:27017 mongo
    echo -e "${GREEN}MongoDB 安装完成!${NC}"
}

uninstall_mongo() {
    echo -e "${BLUE}正在卸载 MongoDB...${NC}"
    docker stop mongo && docker rm mongo
    echo -e "${GREEN}MongoDB 已卸载!${NC}"
}

# 主菜单
while true; do
    echo -e "${BLUE}请选择操作:${NC}"
    echo "1) 安装 MySQL"
    echo "2) 卸载 MySQL"
    echo "3) 安装 Redis"
    echo "4) 卸载 Redis"
    echo "5) 安装 MongoDB"
    echo "6) 卸载 MongoDB"
    echo "q) 退出"
    read -p "输入选项: " choice

    case $choice in
        1) install_mysql ;;
        2) uninstall_mysql ;;
        3) install_redis ;;
        4) uninstall_redis ;;
        5) install_mongo ;;
        6) uninstall_mongo ;;
        q) exit 0 ;;
        *) echo -e "${RED}无效选项,请重试!${NC}" ;;
    esac
done