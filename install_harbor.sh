#/bin/bash

HARBOR_VERSION=2.10.1
HARBOR_NAME="harbor.zqh.org"
HARBOR_ADMIN_PASSWORD="123456"

install_harbor() {
    echo "Installing Harbor..."
    if [ ! -e  harbor-offline-installer-v"$HARBOR_VERSION".tgz ]; then
        wget https://github.com/goharbor/harbor/releases/download/v"$HARBOR_VERSION"/harbor-offline-installer-v"$HARBOR_VERSION".tgz || echo "Failed to download harbor installer."
    fi
    tar xvf harbor-offline-installer-v"$HARBOR_VERSION".tgz -C /usr/local/
    cd /usr/local/harbor
    cp harbor.yml.tmpl harbor.yml
    sed -ri "/^hostname/s/reg.mydomain.com/${HARBOR_NAME}/" harbor.yml
    sed -ri "/^https/s/(https:)/#\1/" harbor.yml
    sed -ri "s/(port: 443)/#\1/" harbor.yml
    sed -ri "/certificate:/s/(.*)/#\1/" harbor.yml
    sed -ri "/private_key:/s/(.*)/#\1/" harbor.yml
    sed -ri "s/Harbor12345/${HARBOR_ADMIN_PASSWORD}/" harbor.yml
    sed -i 's#^data_volume: /data#data_volume: /data/harbor#' harbor.yml
    
    if /usr/local/harbor/install.sh; then
        echo "Successfully started Harbor!"
    else
        "Failed to start Harbor."
        exit 1
    fi
        
    echo "Completed!"
    echo "-------------------------------------------------------------------"
    echo "URL: http://${HARBOR_NAME}" 
}

install_harbor
