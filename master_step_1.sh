#!/bin/bash

if [[ "$EUID" -ne 0 ]] ; then
  echo "Please run as root or with sudo"
  exit 1
fi

sudo apt update
sudo apt upgrade -y
sudo apt install openssh-server net-tools iputils-ping vim ufw less -y
sudo apt install libseccomp2 libseccomp-dev -y
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo apt install -y systemd-timesyncd
sudo timedatectl set-ntp true
sudo timedatectl status
sudo systemctl enable --now ssh
sudo systemctl status ssh

# Setup networking pre-requisites
# In my case, all my machines are on the private network of 10.12.1.0/24

echo "Setting up network ports"
sudo ufw allow from 10.12.1.0/24 to any port 22
sudo ufw allow from 10.12.1.0/24 to any port 6443
sudo ufw allow from 10.12.1.0/24 to any port 10250
sudo ufw allow from 10.12.1.0/24 to any port 10259
sudo ufw allow from 10.12.1.0/24 to any port 10257
sudo ufw allow from 10.12.1.0/24 to any port 2379
sudo ufw allow from 10.12.1.0/24 to any port 2380
sudo ufw logging high
sudo ufw --force enable
sudo ufw status verbose

IP_FWD_FILE="/etc/sysctl.d/k8s.conf"
read -r -d '' IP_FWD_CONFIG <<'EOF'
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

echo "Creating $IP_FWD_FILE..."
echo "$IP_FWD_CONFIG" > "$IP_FWD_FILE"
echo "$IP_FWD_FILE has been created."
sudo sysctl --system

echo "Installing containerd"
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

# Create the initial default config file
sudo mkdir -p /etc/containerd
sudo containerd config default|sudo tee /etc/containerd/config.toml

CRICTL_FILE="/etc/crictl.yaml"
read -r -d '' CRICTL_CONFIG <<'EOF'
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true
pull-image-on-create: false
EOF

echo "Creating $CRICTL_FILE..."
echo "$CRICTL_CONFIG" > "$CRICTL_FILE"
echo "$CRICTL_FILE has been created."

# ====== Create /etc/modules-load.d/k8s.conf ======
MODULES_FILE="/etc/modules-load.d/k8s.conf"
read -r -d '' MODULES_CONFIG <<'EOF'
overlay
br_netfilter
EOF

echo "Creating $MODULES_FILE..."
echo "$MODULES_CONFIG" > "$MODULES_FILE"
echo "$MODULES_FILE has been created."

sudo modprobe overlay
sudo modprobe br_netfilter