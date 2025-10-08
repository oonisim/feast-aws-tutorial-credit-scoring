#!/usr/bin/env bash
# Update the system
sudo dnf update -y

# Install Docker using dnf
sudo dnf install -y docker

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run docker without sudo)
sudo usermod -a -G docker "$(whoami)"

# Apply group changes (logout/login or use newgrp)
newgrp docker

# Verify installation
docker --version
docker info