#!/bin/bash
# If you restart the machine, Kubernetes will not come up automatically.
# Execute this on the master or worker (whichever was restarted) to bring back Kubernetes

if [[ "$EUID" -ne 0 ]] ; then
  echo "Please run as root or with sudo"
  exit 1
fi

echo "Restarting containerd"
sudo systemctl restart containerd

echo "Reloading daemons"
sudo systemctl daemon-reload

echo "Restarting kubelet"
sudo systemctl restart kubelet

echo "Done"
