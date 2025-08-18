#!/bin/bash

# Exit if any command fails
set -e

# 1. Install docker and Add current user to docker group
echo "Installing docker and Adding user '$USER' to docker group..."
sudo apt update -y
sudo apt install docker.io -y
sudo usermod -aG docker ubuntu

# ⚠️ 'newgrp' won't work as expected in non-interactive scripts — better to re-login manually if needed
echo "You must log out and log back in (or run 'newgrp docker') for group changes to take effect."

# 2. Install Java (OpenJDK 21)
echo "Installing OpenJDK 21..."
sudo apt update
sudo apt install -y fontconfig openjdk-21-jre
java -version

# 3. Add Jenkins repo and install Jenkins
echo "Setting up Jenkins repository..."
sudo mkdir -p /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "Installing Jenkins..."
sudo apt-get update
sudo apt-get install -y jenkins

# 4. Enable and start Jenkins service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# 5. Add Jenkins user to docker group
echo "Adding 'jenkins' user to docker group..."
sudo usermod -aG docker jenkins

# 6. Display initial admin password
echo "Waiting a few seconds for Jenkins to initialize..."
sleep 10

echo "Initial Jenkins admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
