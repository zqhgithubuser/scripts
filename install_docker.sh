#!/bin/bash

# 设置严格模式
set -euo pipefail

# 常量定义
readonly DOCKER_REPO_URL="https://mirrors.aliyun.com/docker-ce"

# 获取系统发行版
detect_distribution() {
    if [[ ! -f /etc/os-release ]]; then
        echo "无法确定系统发行版" >&2
        exit 1
    fi

    local distro
    distro=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    echo "${distro}"
}

# 获取系统版本代号
detect_version_codename() {
    if [[ ! -f /etc/os-release ]]; then
        echo "无法确定系统版本代号" >&2
        exit 1
    fi

    local codename
    codename=$(grep "^VERSION_CODENAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
    echo "${codename}"
}

# Ubuntu系统安装Docker
setup_docker_ubuntu() {
    echo "正在为Ubuntu系统安装Docker..."
    
    # 安装依赖
    apt-get update
    apt-get install -y ca-certificates curl
    
    # 配置Docker仓库
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "${DOCKER_REPO_URL}/linux/ubuntu/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    
    # 添加Docker源
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] ${DOCKER_REPO_URL}/linux/ubuntu $(detect_version_codename) stable" \
        | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # 安装Docker
    apt-get update
    apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
}

# CentOS/Rocky系统安装Docker
setup_docker_centos() {
    echo "正在为CentOS/Rocky系统安装Docker..."
    
    # 安装依赖
    yum install -y yum-utils
    
    # 添加Docker仓库
    yum-config-manager --add-repo "${DOCKER_REPO_URL}/linux/centos/docker-ce.repo"
    
    # 安装Docker
    yum install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    # 启动Docker服务
    systemctl enable docker
    systemctl start docker
}

# 安装Docker
install_docker() {
    local distro=$1
    echo "开始安装Docker..."

    case "${distro}" in
        ubuntu)
            setup_docker_ubuntu
            ;;
        centos|rocky)
            setup_docker_centos
            ;;
        *)
            echo "不支持的系统发行版: ${distro}" >&2
            exit 1
            ;;
    esac
}

# 验证Docker安装
check_docker_installation() {
    if ! command -v docker &> /dev/null; then
        echo "Docker安装失败" >&2
        exit 1
    fi

    echo "Docker安装成功！"
    docker --version
}

# 主函数
main() {
    # 检查root权限
    if [[ ${EUID} -ne 0 ]]; then
        echo "此脚本需要root权限运行" >&2
        exit 1
    fi

    # 获取系统信息并安装
    local distro
    distro=$(detect_distribution)
    install_docker "${distro}"
    check_docker_installation
}

# 脚本入口
main

echo "安装完成！"
