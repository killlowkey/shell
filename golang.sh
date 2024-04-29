#!/bin/bash

# 颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 函数:打印错误消息并退出
error_exit() {
  echo -e "${RED}错误:${1}${NC}" >&2
  exit 1
}

# 函数:打印成功消息
success_msg() {
  echo -e "${GREEN}${1}${NC}"
}

# 函数:打印警告消息
warning_msg() {
  echo -e "${YELLOW}${1}${NC}"
}

# 函数:安装 Golang
install_golang() {
  warning_msg "将要安装 Golang..."

  # 检查是否已安装
  if command -v go &>/dev/null; then
    error_exit "Golang 已经安装,无需重复安装。"
  fi

  # 获取 Golang 版本
  read -p "请输入要安装的 Golang 版本 (默认为 1.22.1): " GO_VERSION
  GO_VERSION=${GO_VERSION:-1.22.1}

  # 检查 CPU 架构
  CPU_ARCH=$(uname -m)
  case $CPU_ARCH in
    x86_64) GO_ARCH="amd64" ;;
    aarch64) GO_ARCH="arm64" ;;
    *) error_exit "不支持的 CPU 架构: $CPU_ARCH" ;;
  esac

  # 下载并安装 Golang
  GO_PACKAGE="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  GO_DOWNLOAD_URL="https://go.dev/dl/${GO_PACKAGE}"

  # wget 不关闭 ssl 检查和开启重定向，无法下载
  warning_msg "正在下载 ${GO_PACKAGE}..."
  if ! wget --max-redirect=3 --no-check-certificate "${GO_DOWNLOAD_URL}"; then
    error_exit "下载 Golang 失败。"
  fi

  warning_msg "正在安装 Golang..."
  sudo tar -C /usr/local -xzf "${GO_PACKAGE}"
  rm "${GO_PACKAGE}"

  # 设置环境变量
  warning_msg "正在设置环境变量..."
  {
    echo "export GOROOT=/usr/local/go"
    echo "export GOPATH=/usr/local/gopath"
    echo "export PATH=\$PATH:\$GOPATH/bin:\$GOROOT/bin"
  } | sudo tee -a /etc/profile >/dev/null

  source /etc/profile

  # 设置 Go 模块代理和支持
  go env -w GOPROXY=https://goproxy.io,direct
  go env -w GO111MODULE=on

  success_msg "Golang ${GO_VERSION} 安装成功!"
}

# 函数:卸载 Golang
uninstall_golang() {
  warning_msg "将要卸载 Golang..."

  # 检查是否已安装
  if ! command -v go &>/dev/null; then
    error_exit "Golang 未安装,无需卸载。"
  fi

  # 清除环境变量
  warning_msg "正在清除环境变量..."
  sudo sed -i '/GOROOT/d;/GOPATH/d;/gopath/d' /etc/profile
  source /etc/profile

  # 删除安装目录
  warning_msg "正在删除安装目录..."
  sudo rm -rf /usr/local/go /usr/local/gopath

  success_msg "Golang 卸载成功!"
}

# 函数:安装 Delve (dlv)
install_delve() {
  warning_msg "将要安装 Delve (dlv)..."

  # 检查是否已安装 Golang
  if ! command -v go &>/dev/null; then
    error_exit "Golang 未安装,无法安装 Delve (dlv)。"
  fi

  warning_msg "正在安装 Delve (dlv)..."
  go install github.com/go-delve/delve/cmd/dlv@latest
  if [ $? -ne 0 ]; then
    error_exit "安装 Delve (dlv) 失败。"
  fi

  success_msg "Delve (dlv) 安装成功!"
}

# 主程序
echo -e "${GREEN}请选择操作:${NC}"
echo "1) 安装 Golang"
echo "2) 卸载 Golang"
echo "3) 安装 Delve (dlv)"
read -p "请输入操作序号 (1、2 或 3): " choice

case $choice in
  1) install_golang ;;
  2) uninstall_golang ;;
  3) install_delve ;;
  *) error_exit "无效的选择。" ;;
esac