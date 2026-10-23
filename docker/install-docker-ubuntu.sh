
#!/usr/bin/env bash
set -euo pipefail

# Install prerequisites
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
  sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" |
  sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable Docker
sudo systemctl enable --now docker

# Verify installation
sudo docker version
sudo docker compose version
ls -l /var/run/docker.sock /run/docker.sock

echo "Docker installation completed successfully!"

# Label this node as Docker-enabled in k3s
NODE_NAME=$(hostname)
if command -v kubectl >/dev/null 2>&1; then
    sudo k3s kubectl label node "$NODE_NAME" docker=enabled --overwrite
    echo "Node $NODE_NAME labelled docker=enabled"
fi
