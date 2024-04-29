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
        read -p "请输入 MySQL 5.7 数据目录(默认为 /usr/local/data/mysql5.7): " mysql57_data_dir
        mysql57_data_dir=${mysql57_data_dir:-/usr/local/data/mysql5.7}
        mkdir -p "$mysql57_data_dir"

        echo -e "${BLUE}正在安装 MySQL 5.7...${NC}"
        docker run -d --name mysql57 -p 3306:3306 -e MYSQL_ROOT_PASSWORD="$mysql_password" -v "$mysql57_data_dir":/var/lib/mysql mysql:5.7
        echo -e "${GREEN}MySQL 5.7 安装完成!${NC}"
        ;;
    2)
        read -p "请输入 MySQL 8.0 数据目录(默认为 /usr/local/data/mysql8.0): " mysql80_data_dir
        mysql80_data_dir=${mysql80_data_dir:-/usr/local/data/mysql8.0}
        mkdir -p "$mysql80_data_dir"

        echo -e "${BLUE}正在安装 MySQL 8.0...${NC}"
        docker run -d --name mysql80 -p 3307:3306 -e MYSQL_ROOT_PASSWORD="$mysql_password" -v "$mysql80_data_dir":/var/lib/mysql mysql:8.0
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
    read -p "请输入 Redis 数据目录(默认为 /usr/local/data/redis): " redis_data_dir
    redis_data_dir=${redis_data_dir:-/usr/local/data/redis}
    mkdir -p "$redis_data_dir"

    echo -e "${BLUE}正在安装 Redis...${NC}"
    docker run -d --name redis -p 6379:6379 -v "$redis_data_dir":/data redis
    echo -e "${GREEN}Redis 安装完成!${NC}"
}

uninstall_redis() {
    echo -e "${BLUE}正在卸载 Redis...${NC}"
    docker stop redis && docker rm redis
    echo -e "${GREEN}Redis 已卸载!${NC}"
}

install_mongo() {
    read -p "请输入 MongoDB 数据目录(默认为 /usr/local/data/mongo): " mongo_data_dir
    mongo_data_dir=${mongo_data_dir:-/usr/local/data/mongo}
    mkdir -p "$mongo_data_dir"

    echo -e "${BLUE}正在安装 MongoDB...${NC}"
    docker run -d --name mongo -p 27017:27017 -v "$mongo_data_dir":/data/db mongo
    echo -e "${GREEN}MongoDB 安装完成!${NC}"
}

uninstall_mongo() {
    echo -e "${BLUE}正在卸载 MongoDB...${NC}"
    docker stop mongo && docker rm mongo
    echo -e "${GREEN}MongoDB 已卸载!${NC}"
}

install_postgres() {
    read -p "请输入 PostgreSQL 数据目录(默认为 /usr/local/data/postgres): " postgres_data_dir
    postgres_data_dir=${postgres_data_dir:-/usr/local/data/postgres}
    mkdir -p "$postgres_data_dir"

    echo -e "${BLUE}正在安装 PostgreSQL...${NC}"
    docker run -d --name postgres -p 5432:5432 -v "$postgres_data_dir":/var/lib/postgresql/data postgres
    echo -e "${GREEN}PostgreSQL 安装完成!${NC}"
}

uninstall_postgres() {
    echo -e "${BLUE}正在卸载 PostgreSQL...${NC}"
    docker stop postgres && docker rm postgres
    echo -e "${GREEN}PostgreSQL 已卸载!${NC}"
}

install_etcd() {
    read -p "请输入 Etcd 数据目录(默认为 /usr/local/data/etcd): " etcd_data_dir
    etcd_data_dir=${etcd_data_dir:-/usr/local/data/etcd}
    mkdir -p "$etcd_data_dir"

    echo -e "${BLUE}正在安装 Etcd...${NC}"
    docker run -d --name etcd -p 2379:2379 -p 2380:2380 -v "$etcd_data_dir":/etcd-data quay.io/coreos/etcd
    echo -e "${GREEN}Etcd 安装完成!${NC}"
}

uninstall_etcd() {
    echo -e "${BLUE}正在卸载 Etcd...${NC}"
    docker stop etcd && docker rm etcd
    echo -e "${GREEN}Etcd 已卸载!${NC}"
}

install_kafka() {
    read -p "请输入 Kafka 数据目录(默认为 /usr/local/data/kafka): " kafka_data_dir
    kafka_data_dir=${kafka_data_dir:-/usr/local/data/kafka}
    mkdir -p "$kafka_data_dir"

    echo -e "${BLUE}正在安装 Kafka...${NC}"
    docker run -d --name kafka -p 9092:9092 -v "$kafka_data_dir":/kafka -e KAFKA_ADVERTISED_HOST_NAME=`hostname -i` wurstmeister/kafka
    echo -e "${GREEN}Kafka 安装完成!${NC}"
}

uninstall_kafka() {
    echo -e "${BLUE}正在卸载 Kafka...${NC}"
    docker stop kafka && docker rm kafka
    echo -e "${GREEN}Kafka 已卸载!${NC}"
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
    echo "7) 安装 PostgreSQL"
    echo "8) 卸载 PostgreSQL"
    echo "9) 安装 Etcd"
    echo "10) 卸载 Etcd"
    echo "11) 安装 Kafka"
    echo "12) 卸载 Kafka"
    echo "q) 退出"
    read -p "输入选项: " choice

    case $choice in
        1) install_mysql ;;
        2) uninstall_mysql ;;
        3) install_redis ;;
        4) uninstall_redis ;;
        5) install_mongo ;;
        6) uninstall_mongo ;;
        7) install_postgres ;;
        8) uninstall_postgres ;;
        9) install_etcd ;;
        10) uninstall_etcd ;;
        11) install_kafka ;;
        12) uninstall_kafka ;;
        q) exit 0 ;;
        *) echo -e "${RED}无效选项,请重试!${NC}" ;;
    esac
done