#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or with sudo"
  exit 1
fi

# These instructions are to create the master node on a virtual machine in Truenas Scale (Fangtooth)

# Steps to be performed before running this script:
# Create a ZVol of size 10 GiB that will act as the disk on which we will install Ubuntu Server 24.04
# Download the ISO image from the internet and upload it to Truenas
 
# Create a new instance with these parameters through the GUI
# -----------------------------------------------------------
# 2 CPU
# 8 GiB RAM
# 6 GiB Root Disk
# Attached ZVol onto which the OS will be installed
# Select the appropriate NIC
# Setup a VNC port of 5901 (so that it does not clash with 5900 already in use)
# 
# Use a VNC viewer (Screen Sharing app on iMac) to login to the machine
# and begin the Ubuntu installation process
# Choose the minimized image
# I did not choose OpenSSH server from the GUI installation steps, but maybe I should.
# Once installation is complete, and reboot is done, login to the machine through the VNC client
# Run the command
# ip a
# This will show the MAC address of the interface
# Create a DHCP reservation in the router to assign the IP address 10.12.1.12 to this MAC address
# Restart both the router and the VM, this should now take effect. Verify by running ip a again.

# Verify that swap space is off
# nikhil@k8smaster:~$ free -m
#                total        used        free      shared  buff/cache   available
# Mem:            7929         513        6905           4         826        7416
# Swap:              0           0           0

# Initially, ipv4 forwarding is off
# nikhil@k8smaster:~$ sysctl net.ipv4.ip_forward
# net.ipv4.ip_forward = 0

# nikhil@k8smaster:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
# > net.ipv4.ip_forward = 1
# > EOF
# net.ipv4.ip_forward = 1
# sudo sysctl --system

# Check which cgroup driver is being used on the system
# nikhil@k8smaster:~$ stat -fc %T /sys/fs/cgroup/
# cgroup2fs


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
