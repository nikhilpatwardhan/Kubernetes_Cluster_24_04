#!/bin/bash

# If you restart the machine, Kubernetes will not come up automatically.
# Execute this on the master or worker (whichever was restarted) to bring back Kubernetes
echo "Restarting containerd"
sudo systemctl restart containerd

echo "Reloading daemons"
sudo systemctl daemon-reload

echo "Restarting kubelet"
sudo systemctl restart kubelet

echo "Done"
kubectl get nodes
