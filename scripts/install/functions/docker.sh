#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing Docker"

# Uninstall old versions:
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo apt-get remove $pkg;
done

# Add Docker's official GPG key:
sudo apt-get update 
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Manage docker as a non-root user
if ! getent group docker > /dev/null; then
    echo "🔧 Creating docker group"
    sudo groupadd docker
fi

sudo usermod -aG docker "$USER"

if [ ! -d "/etc/docker" ]; then
    echo "🔧 Creating docker directory"
    sudo mkdir -p /etc/docker

    echo "🔧 Creating docker daemon.json"
    sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
    {
      "insecure-registries": [
        "auth.docker.io:443",
        "registry.docker.io:443",
        "registry-1.docker.io:443",
        "docker.io:443",
        "artifactory.topdanmark.local:443"
      ],
      "registry-mirrors": [
        "https://artifactory.topdanmark.local/artifactory/docker"
      ]
    }
EOF
fi

# Self signed cert with docker
if [ ! -d "/etc/docker/certs.d/artifactory.topdanmark.local" ]; then
    echo "🔧 Creating artifactory cert directory for docker"
    sudo mkdir -p /etc/docker/certs.d/artifactory.topdanmark.local:443
fi

# Configure Docker to start on boot with systemd
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

# Start Docker and containerd services
sudo systemctl start docker.service
sudo systemctl start containerd.service

# Wait until Docker is active (started and ready)
echo "⏳ Waiting for Docker to start..."
until sudo systemctl is-active --quiet docker.service; do
   sleep 1
done

echo "✅ Docker is running"

echo "🔧 Testing Docker installation"

if sudo docker run hello-world; then
    echo "🎉 Docker installed successfully"
else
    echo "🤯 Docker installation failed"
fi
