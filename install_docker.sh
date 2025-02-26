#!/bin/bash

repository_url=https://mirrors.aliyun.com/docker-ce

get_os_type() {
    local os_type="$(. /etc/os-release && echo "$ID")"
    echo "$os_type"
}

get_os_version() {
    local os_version=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo "$os_version"
}

do_install() {
    local os_type=$( get_os_type )    
    echo "Installing Docker..."

    case "$os_type" in
        ubuntu)
            apt update && apt install -y ca-certificates curl
            install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
            chmod a+r /etc/apt/keyrings/docker.asc
            echo \
                "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] $repository_url/linux/ubuntu \
                $( get_os_version ) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
        centos|rocky)
            yum install -y yum-utils
            yum-config-manager --add-repo "$repository_url"/linux/centos/docker-ce.repo
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
