#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# docker compose kafka 配置
# https://github.com/conduktor/kafka-stack-docker-compose
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker 未安装!${NC}"
        exit 1
    fi

    if ! command -v docker compose &> /dev/null; then
        echo -e "${RED}Docker Compose 未安装!${NC}"
        exit 1
    fi
}

download_config() {
    config_dir="$HOME/.kafka"
    mkdir -p "$config_dir"

    case $1 in
        1)
            config_file="$config_dir/zk-single-kafka-single.yml"
            if [ ! -f "$config_file" ]; then
                curl -o "$config_file" https://raw.githubusercontent.com/conduktor/kafka-stack-docker-compose/master/zk-single-kafka-single.yml
            fi
            ;;
        2)
            config_file="$config_dir/zk-single-kafka-multiple.yml"
            if [ ! -f "$config_file" ]; then
                curl -o "$config_file" https://raw.githubusercontent.com/conduktor/kafka-stack-docker-compose/master/zk-single-kafka-multiple.yml
            fi
            ;;
        3)
            config_file="$config_dir/zk-multiple-kafka-single.yml"
            if [ ! -f "$config_file" ]; then
                curl -o "$config_file" https://github.com/conduktor/kafka-stack-docker-compose/raw/master/zk-multiple-kafka-single.yml
            fi
            ;;
        4)
            config_file="$config_dir/zk-multiple-kafka-multiple.yml"
            if [ ! -f "$config_file" ]; then
                curl -o "$config_file" https://github.com/conduktor/kafka-stack-docker-compose/raw/master/zk-multiple-kafka-multiple.yml
            fi
            ;;
        5)
            config_file="$config_dir/zk-multiple-kafka-multiple-schema-registry.yml"
            if [ ! -f "$config_file" ]; then
                curl -o "$config_file" https://raw.githubusercontent.com/conduktor/kafka-stack-docker-compose/master/zk-multiple-kafka-multiple-schema-registry.yml
            fi
            ;;
        *)
            echo -e "${RED}无效选项!${NC}"
            exit 1
    esac
}

install_kafka() {
    echo -e "${BLUE}正在安装 Kafka...${NC}"
    docker compose -f "$config_file" up -d
    echo -e "${GREEN}Kafka 安装完成!${NC}"
}

uninstall_kafka() {
    echo -e "${BLUE}正在卸载 Kafka...${NC}"
    docker compose -f "$config_file" down
    echo -e "${GREEN}Kafka 已卸载!${NC}"
}

check_dependencies

echo "请选择要安装的 Kafka 配置:"
echo "1. 单 Zookeeper,单 Kafka Broker"
echo "2. 单 Zookeeper,多 Kafka Broker"
echo "3. 多 Zookeeper,单 Kafka Broker"
echo "4. 多 Zookeeper,多 Kafka Broker"
echo "5. 多 Zookeeper,多 Kafka Broker,Schema Registry"
read -p "输入选项号(1-5): " choice

download_config "$choice"

echo "请选择操作:"
echo "1. 安装 Kafka"
echo "2. 卸载 Kafka"
read -p "输入选项号(1-2): " action

case $action in
    1)
        install_kafka
        ;;
    2)
        uninstall_kafka
        ;;
    *)
        echo -e "${RED}无效选项!${NC}"
        exit 1
esac
