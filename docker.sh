#!/bin/bash

# 颜色变量
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

# 函数:打印成功消息
success_msg() {
  echo -e "${GREEN}${1}${NC}"
}

# 函数:打印警告消息
warning_msg() {
  echo -e "${YELLOW}${1}${NC}"
}

# 函数:打印错误消息并退出
error_exit() {
  echo -e "${RED}错误:${1}${NC}" >&2
  exit 1
}

# 函数:安装 Docker
install_docker() {
  # 检查是否已安装 Docker
  if command -v docker &>/dev/null; then
    error_exit "Docker 已经安装,无需重复安装。"
  fi

  # 设置 Docker 的 repo 源
  warning_msg "正在设置 Docker 的 repo 源..."
  sudo yum update
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  # 安装和启动 Docker
  warning_msg "正在安装 Docker..."
  sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl start docker

  # 设置国内源
  warning_msg "正在设置国内源..."
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://ibirju58.mirror.aliyuncs.com"]
}
EOF
  sudo systemctl daemon-reload
  sudo systemctl restart docker

  success_msg "Docker 安装成功!"
  sudo docker info
}

# 函数:卸载 Docker
uninstall_docker() {
  warning_msg "正在卸载 Docker..."

  # 停止并卸载 Docker
  warning_msg "正在停止并卸载 Docker..."
  sudo systemctl stop docker
  sudo yum remove docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras  

  # 删除 Docker 相关目录
  warning_msg "正在删除 Docker 相关目录..."
  sudo rm -rf /var/lib/docker
  sudo rm -rf /etc/docker
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd

  success_msg "Docker 卸载成功!"
}

# 主程序
echo -e "${GREEN}请选择操作:${NC}"
echo "1) 安装 Docker"
echo "2) 卸载 Docker"
read -p "请输入操作序号 (1 或 2): " choice

case $choice in
  1) install_docker ;;
  2) uninstall_docker ;;
  *) error_exit "无效的选择。" ;;
esac
