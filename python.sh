#!/bin/bash

# 颜色常量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Python 版本号
PYTHON_VERSION="3.9.6"

echo -e "${GREEN}开始安装 Python ${PYTHON_VERSION}${NC}"

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}请使用 root 用户运行此脚本${NC}"
    exit 1
fi

# 卸载本地 Python 版本
echo -e "${YELLOW}卸载本地 Python 版本...${NC}"
yum remove python3 -y

# 安装依赖包
echo -e "${YELLOW}安装依赖包...${NC}"
yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel sqlite-devel -y

# 下载 Python 源码
PYTHON_URL="https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz"
echo -e "${YELLOW}下载 Python 源码...${NC}"
wget "${PYTHON_URL}"

# 解压并编译安装
echo -e "${YELLOW}解压并编译安装 Python...${NC}"
tar -xvf "Python-${PYTHON_VERSION}.tgz"
cd "Python-${PYTHON_VERSION}"
./configure --enable-optimizations
make
make altinstall

# 验证 Python 版本
echo -e "${GREEN}Python 版本:${NC}"
python${PYTHON_VERSION/./} --version

# 配置 .bashrc 文件
echo -e "${YELLOW}配置 .bashrc 文件...${NC}"
if ! grep -q "alias python3=\"/usr/local/bin/python${PYTHON_VERSION/./}\"" ~/.bashrc; then
    echo "alias python3=\"/usr/local/bin/python${PYTHON_VERSION/./}\"" >> ~/.bashrc
fi
if ! grep -q "alias pip3=\"/usr/local/bin/pip${PYTHON_VERSION/./}\"" ~/.bashrc; then
    echo "alias pip3=\"/usr/local/bin/pip${PYTHON_VERSION/./}\"" >> ~/.bashrc
fi
source ~/.bashrc

# 验证 Python 和 pip 路径
echo -e "${GREEN}Python 路径:${NC}"
which python3
echo -e "${GREEN}pip 路径:${NC}"
which pip3

# 设置 Python 清华代理源
echo -e "${YELLOW}设置 Python 清华代理源...${NC}"
mkdir -p ~/.pip
if ! grep -q "\[global\]" ~/.pip/pip.conf; then
    echo "[global]" >> ~/.pip/pip.conf
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
fi
if ! grep -q "\[install\]" ~/.pip/pip.conf; then
    echo "[install]" >> ~/.pip/pip.conf
    echo "trusted-host = https://pypi.tuna.tsinghua.edu.cn" >> ~/.pip/pip.conf
fi

echo -e "${GREEN}Python ${PYTHON_VERSION} 安装成功!${NC}"