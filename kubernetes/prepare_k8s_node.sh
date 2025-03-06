#!/bin/bash

sudo apt update
sudo apt install -y net-tools tcpdump chrony bridge-utils wget

# 禁用 swap
systemctl --type swap
sudo systemctl mask swap.img.swap
sudo sed -i 's/.*swap/#&/' /etc/fstab
sudo swapoff -a

# 启用内核模块
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# 配置内核参数
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# 安装 Docker
sudo apt update && sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://mirrors.aliyun.com/docker-ce/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
# apt-cache madison docker-ce | awk '{ print $3 }'
sudo apt install -y docker-ce=5:23.0.6-1~ubuntu.22.04~jammy \
                    docker-ce-cli=5:23.0.6-1~ubuntu.22.04~jammy \
                    containerd.io \
                    docker-buildx-plugin \
                    docker-compose-plugin

# Docker 使用 systemd 作为 cgroup 驱动
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload
sudo systemctl restart docker.service

# 安装 cri-dockerd
wget https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.1/cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb
sudo dpkg -i cri-dockerd_0.3.1.3-0.ubuntu-jammy_amd64.deb
systemctl status cri-docker.service

sudo sed -ri 's|(ExecStart.*)|\1 --network-plugin=cni --cni-bin-dir=/opt/cni/bin --cni-cache-dir=/var/lib/cni/cache --cni-conf-dir=/etc/cni/net.d --pod-infra-container-image=registry.aliyuncs.com/google_containers/pause:3.9|g' /lib/systemd/system/cri-docker.service
sudo systemctl daemon-reload
sudo systemctl restart cri-docker.service

# 添加 Kubernetes 阿里云镜像源
curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.28/deb/Release.key |
    sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.27/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
