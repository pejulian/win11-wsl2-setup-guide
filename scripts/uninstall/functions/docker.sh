#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling Docker"

if command -v docker >/dev/null 2>&1; then
    # Removing docker self signed cert config and daemon config
    if [ -d "/etc/docker" ]; then
        echo "🔧 Removing docker directory"
        sudo rm -rf /etc/docker
    fi

    echo "🔧 Stopping Docker service"
    sudo systemctl disable --now docker.service containerd.service

    echo "🔧 Removing Docker packages"
    sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo apt-get autoremove -y --purge
    sudo apt-get clean

    echo "🔧 Removing Docker directories and configuration files"
    sudo rm -rf /etc/apt/sources.list.d/docker.list
    sudo rm -rf /etc/apt/keyrings/docker.asc
    sudo rm -rf /var/lib/docker
    sudo rm -rf /var/lib/containerd

    echo "🔧 Removing Docker group"
    if getent group docker > /dev/null; then
        sudo gpasswd -d "$USER" docker 
        sudo groupdel docker
    fi  
fi

echo "✅ Docker uninstalled"
