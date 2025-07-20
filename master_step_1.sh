#!/bin/bash

if [ "$EUID" -ne 0 ]
then
  echo "Please run as root or with sudo"
  exit 1
fi


# Overall the steps we are following are those documented in
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md
# https://github.com/containerd/containerd/releases

sudo apt update
sudo apt install openssh-server net-tools vim ufw -y
sudo apt install libseccomp2 libseccomp-dev -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo apt install systemd-timesyncd
sudo timedatectl set-ntp true
sudo timedatectl status
sudo systemctl enable —now ssh
sudo systemctl status ssh

# Setup networking pre-requisites
# In my case, my workers will be on the private network of 10.12.1.0/24

sudo ufw allow ssh from 10.12.1.10/24
sudo ufw enable
sudo ufw status verbose
sudo ufw allow from 10.12.1.0/24 to any port 6443
sudo ufw allow from 10.12.1.0/24 to any port 10250
sudo ufw allow from 10.12.1.0/24 to any port 10259
sudo ufw allow from 10.12.1.0/24 to any port 10257
sudo ufw allow from 10.12.1.0/24 to any port 2379
sudo ufw allow from 10.12.1.0/24 to any port 2380

# Install containerd
wget https://github.com/containerd/containerd/releases/download/v2.1.3/containerd-2.1.3-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-2.1.3-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /lib/systemd/system
sudo systemctl start containerd

wget https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

# Install CNI Plugins
wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz

# Prepare for systemd
sudo mkdir -p /etc/containerd

TARGET_FILE="/etc/crictl.yaml"

# Define the contents
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true
pull-image-on-create: false
EOF

# Create or overwrite the file
echo "Creating $TARGET_FILE ..."
echo "$CONTENT" > "$TARGET_FILE"

echo "$TARGET_FILE created successfully."
