#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update system packages
echo "Updating package list..."
sudo apt update -y

# Install unzip if not already installed
echo "Installing unzip..."
sudo apt install unzip -y

# Download and install AWS CLI v2
echo "Downloading AWS CLI v2..."

# Go to a safe directory
cd ~/

# Remove old files if they exist
rm -rf awscliv2.zip aws

# Download the latest AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip it
unzip awscliv2.zip

# Install or update
sudo ./aws/install --update

# Download the latest version of kubectl
echo "Downloading latest kubectl release..."
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl.sha256"

# Verify kubectl binary checksum
echo "Verifying kubectl checksum..."
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Install kubectl
echo "Installing kubectl..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Optional: Also place kubectl in user's local bin for easy access
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl

# Confirm kubectl installation
echo "kubectl installation completed ✅"
kubectl version --client

