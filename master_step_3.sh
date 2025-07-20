#!/bin/bash

if [[ "$EUID" -ne 0 ]] ; then
  echo "Please run as root or with sudo"
  exit 1
fi

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt install -y kubelet=1.33.3-1.1 kubeadm=1.33.3-1.1 kubectl=1.33.3-1.1
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable kubelet

sudo kubeadm config images pull --cri-socket unix:///var/run/containerd/containerd.sock
