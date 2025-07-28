#!/bin/bash

# If you restart the machine, Kubernetes will not come up automatically.
# Execute this on the master or worker (whichever was restarted) to bring back Kubernetes
sudo systemctl restart containerd
sudo systemctl daemon-reload
sudo systemctl restart kubelet
