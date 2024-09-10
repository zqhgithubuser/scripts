#!/bin/bash

NGINX_VERSION=1.22.0
NGINX_SOURCE=nginx-"$NGINX_VERSION".tar.gz
DOWNLOAD_URL=https://nginx.org/download/
INSTALL_DIR=/usr/local/nginx
CPUS=$(grep -c processor /proc/cpuinfo)

get_distribution() {
    local lsb_dist="$(. /etc/os-release && echo "$ID")"
    echo "$lsb_dist"
}

download_nginx() {
    if [ -e "$NGINX_SOURCE" ]; then
        echo "The source code package is ready!"
    else
        echo 'Downloading Nginx source code package...'
        if ! wget "$DOWNLOAD_URL""$NGINX_SOURCE"; then
            echo "Download failed."
            exit 1
        fi
        echo "Download successfully!"
    fi
} 

install_dependencies() {
    echo "Installing dependencies..."

    local lsb_dist=$( get_distribution )
    case "$lsb_dist" in
        ubuntu)
            apt update && apt install -y gcc make libpcre3-dev libssl-dev zlib1g-dev
            ;;
        centos|rocky)
            yum install -y gcc make libtool pcre-devel zlib-devel openssl-devel perl-ExtUtils-Embed
            ;;
        *)
            echo "ERROR: Unsupported operating system."
            exit 1
    esac
}

install_nginx() {
    echo "Installing Nginx..."
    useradd -s /sbin/nologin -r nginx &> /dev/null || echo "user 'nginx' already created."
    tar xf "$NGINX_SOURCE"
    NGINX_DIR=$(echo "$NGINX_SOURCE" | sed -rn 's/^(.*[0-9]).*/\1/p')
    cd "$NGINX_DIR"
    if ! { ./configure --prefix="$INSTALL_DIR" --user=nginx --group=nginx \
        --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
        --with-http_stub_status_module --with-http_gzip_static_module --with-pcre \
        --with-stream --with-stream_ssl_module --with-stream_realip_module && \
        make -j $CPUS && make install; }; then
        echo "Compile and install failed."
        exit 1
    fi
    echo "Compile and install successfully!"
    chown -R nginx:nginx "$INSTALL_DIR"
    echo "export PATH=\$PATH:${INSTALL_DIR}/sbin" > /etc/profile.d/nginx.sh
}

setup_systemd() {
	cat > /lib/systemd/system/nginx.service <<-EOF
	[Unit]
	Description=A high performance web server and a reverse proxy server
	After=network-online.target
	
	[Service]
	Type=forking
	PIDFile=${INSTALL_DIR}/logs/nginx.pid
	ExecStartPre=${INSTALL_DIR}/sbin/nginx -t -q
	ExecStart=${INSTALL_DIR}/sbin/nginx
	ExecReload=${INSTALL_DIR}/sbin/nginx -s reload
	ExecStop=-/usr/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile ${INSTALL_DIR}/logs/nginx.pid
	TimeoutStopSec=3
	KillMode=process
	PrivateTmp=true
	LimitNOFILE=100000
	
	[Install]
	WantedBy=multi-user.target
	EOF
    systemctl daemon-reload
    systemctl enable --now nginx
    if systemctl is-active --quiet nginx; then
        echo "Successfully started Nginx!"
    else
        echo "Failed to start Nginx service."
        exit 1
    fi
}

main() {
    download_nginx
    install_dependencies
    install_nginx
    setup_systemd
    echo "Completed!"
}

main
