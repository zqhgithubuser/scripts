#/bin/bash

harbor_version=2.10.1
harbor_host="harbor.zqh.org"
harbor_admin_password="123456"

install_harbor() {
    echo "Installing Harbor..."

    local installer="harbor-offline-installer-v$harbor_version.tgz"
    if [ ! -e  harbor-offline-installer-v"$harbor_version".tgz ]; then
        if ! wget https://github.com/goharbor/harbor/releases/download/v"$harbor_version"/"$installer"; then
            echo "Failed to download harbor installer."
            exit 1
    fi
    tar xvf "$installer" -C /usr/local/
    cd /usr/local/harbor
    cp harbor.yml.tmpl harbor.yml

    sed -ri "/^hostname/s/reg.mydomain.com/$harbor_host/" harbor.yml
    sed -ri "/^https/s/(https:)/#\1/" harbor.yml
    sed -ri "s/(port: 443)/#\1/" harbor.yml
    sed -ri "/certificate:/s/(.*)/#\1/" harbor.yml
    sed -ri "/private_key:/s/(.*)/#\1/" harbor.yml
    sed -ri "s/Harbor12345/$harbor_admin_password/" harbor.yml
    sed -i 's#^data_volume: /data#data_volume: /data/harbor#' harbor.yml
    
    if /usr/local/harbor/install.sh; then
        echo "Successfully started Harbor!"
    else
        "Failed to start Harbor."
        exit 1
    fi
        
    echo "Completed!"
    echo "-------------------------------------------------------------------"
    echo "URL: http://$harbor_host" 
}

install_harbor
