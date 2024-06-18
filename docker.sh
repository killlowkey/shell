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
  sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl start docker
  sudo systemctl enable docker

  # 设置国内源
  warning_msg "正在设置国内源..."
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json <<EOF
  {
      "registry-mirrors": [
          "https://hub.uuuadc.top",
          "https://docker.anyhub.us.kg",
          "https://dockerhub.jobcher.com",
          "https://dockerhub.icu",
          "https://docker.ckyl.me",
          "https://docker.awsl9527.cn"
      ]
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
  sudo yum remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-ce-rootless-extras  

  # 删除 Docker 相关目录
  warning_msg "正在删除 Docker 相关目录..."
  sudo rm -rf /var/lib/docker
  sudo rm -rf /etc/docker
  sudo rm -rf /var/lib/docker
  sudo rm -rf /var/lib/containerd

  success_msg "Docker 卸载成功!"
}

# 函数:列出系统用户并选择将用户加入 Docker 组
add_user_to_docker_group() {
  # 获取所有非系统用户的列表
  users=($(awk -F: '$3 >= 1000 {print $1}' /etc/passwd))
  echo -e "${GREEN}请选择用户:${NC}"
  echo "0) 所有用户"
  for i in "${!users[@]}"; do
    echo "$((i+1))) ${users[$i]}"
  done
  read -p "请输入用户序号: " user_choice

  if [[ "$user_choice" == "0" ]]; then
    for username in "${users[@]}"; do
      sudo usermod -aG docker "$username"
      success_msg "用户 $username 已加入 docker 组。"
    done
  else
    user_index=$((user_choice-1))
    if [[ $user_index -ge 0 && $user_index -lt ${#users[@]} ]]; then
      selected_user=${users[$user_index]}
      sudo usermod -aG docker "$selected_user"
      success_msg "用户 $selected_user 已加入 docker 组。"
    else
      error_exit "无效的用户选择。"
    fi
  fi
}

# 主程序
echo -e "${GREEN}请选择操作:${NC}"
echo "1) 安装 Docker"
echo "2) 卸载 Docker"
echo "3) 将用户加入 Docker 组"
read -p "请输入操作序号 (1, 2 或 3): " choice

case $choice in
  1) install_docker ;;
  2) uninstall_docker ;;
  3) add_user_to_docker_group ;;
  *) error_exit "无效的选择。" ;;
esac
