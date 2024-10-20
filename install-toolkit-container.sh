#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Download CUDA repository pin file
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin

# Move the pin file to the appropriate location
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Download CUDA repository package
wget https://developer.download.nvidia.com/compute/cuda/12.4.0/local_installers/cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb

# Install the CUDA repository package
sudo dpkg -i cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb

# Copy the CUDA keyring to the appropriate location
sudo cp /var/cuda-repo-ubuntu2204-12-4-local/cuda-*-keyring.gpg /usr/share/keyrings/

# Update the package list
sudo apt-get update

# Install CUDA Toolkit 12.4
sudo apt-get -y install cuda-toolkit-12-4

# Clean up the downloaded .deb file
rm cuda-repo-ubuntu2204-12-4-local_12.4.0-550.54.14-1_amd64.deb

echo "CUDA Toolkit 12.4 installation completed."
