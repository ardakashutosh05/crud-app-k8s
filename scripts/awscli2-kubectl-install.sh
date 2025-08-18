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
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-2.0.30.zip" -o "awscliv2.zip"

echo "Unzipping AWS CLI installer..."
unzip -q awscliv2.zip

echo "Installing AWS CLI v2..."
sudo ./aws/install

echo "AWS CLI v2 installation completed ✅"

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

# Download the latest version of eksctl
echo "Downloading latest eksctl release..."
# Replace amd64 with armv6, armv7 or arm64
 (Get-FileHash -Algorithm SHA256 .\eksctl_Windows_amd64.zip).Hash -eq ((Get-Content .\eksctl_checksums.txt) -match 'eksctl_Windows_amd64.zip' -split ' ')[0]
 ```

#### Using Git Bash: 
```sh
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
ARCH=amd64
PLATFORM=windows_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.zip"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

unzip eksctl_$PLATFORM.zip -d $HOME/bin

rm eksctl_$PLATFORM.zip

# Confirm eksctl installation
echo "eksctl installation completed ✅"
eksctl version -- client
