#!/bin/bash

nginx_version=1.22.0
nginx_source=nginx-"$nginx_version".tar.gz
download_url=https://nginx.org/download/
install_dir=/usr/local/nginx
cpu_cores=$(grep -c processor /proc/cpuinfo)

get_distribution() {
    local lsb_dist="$(. /etc/os-release && echo "$ID")"
    echo "$lsb_dist"
}

download_nginx_source() {
    if [ -e "$nginx_source" ]; then
        echo "The source code package is ready!"
    else
        echo 'Downloading Nginx source code package...'
        if ! wget "$download_url$nginx_source"; then
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
    tar xf "$nginx_source"
    nginx_dir=$(echo "$nginx_source" | sed -rn 's/^(.*[0-9]).*/\1/p')
    cd "$nginx_dir"
    if ! { ./configure --prefix="$install_dir" --user=nginx --group=nginx \
        --with-http_ssl_module --with-http_v2_module --with-http_realip_module \
        --with-http_stub_status_module --with-http_gzip_static_module --with-pcre \
        --with-stream --with-stream_ssl_module --with-stream_realip_module && \
        make -j $cpu_cores && make install; }; then
        echo "Compile and install failed."
        exit 1
    fi
    echo "Compile and install successfully!"
    chown -R nginx:nginx "$install_dir"
    echo "export PATH=\$PATH:${install_dir}/sbin" > /etc/profile.d/nginx.sh
}

setup_nginx_service() {
	cat > /lib/systemd/system/nginx.service <<-EOF
	[Unit]
	Description=A high performance web server and a reverse proxy server
	After=network-online.target
	
	[Service]
	Type=forking
	PIDFile=${install_dir}/logs/nginx.pid
	ExecStartPre=${install_dir}/sbin/nginx -t -q
	ExecStart=${install_dir}/sbin/nginx
	ExecReload=${install_dir}/sbin/nginx -s reload
	ExecStop=-/usr/sbin/start-stop-daemon --quiet --stop --retry QUIT/5 --pidfile ${install_dir}/logs/nginx.pid
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
    download_nginx_source
    install_dependencies
    install_nginx
    setup_nginx_service
}

main

echo "Completed!"
