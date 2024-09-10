#!/bin/bash

DOWNLOAD_URL=https://mirrors.aliyun.com/docker-ce

get_distribution() {
    local lsb_dist="$(. /etc/os-release && echo "$ID")"
    echo "$lsb_dist"
}

get_dist_version() {
    local dist_version=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo "$dist_version"
}

do_install() {
    local lsb_dist=$( get_distribution )    
    echo "Installing Docker..."
    case "$lsb_dist" in
        ubuntu)
            apt update && apt install -y ca-certificates curl
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc
            echo \
                "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] $DOWNLOAD_URL/linux/ubuntu \
                $( get_dist_version ) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        centos|rocky)
            yum install -y yum-utils
            yum-config-manager --add-repo "$DOWNLOAD_URL"/linux/centos/docker-ce.repo
            yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            systemctl enable docker
            systemctl start docker
            ;;
        *)
            echo "ERROR: Unsupported operating system."
            exit 1
    esac
}

do_install
echo "Completed!"
