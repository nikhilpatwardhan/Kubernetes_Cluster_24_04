If you restart the machine on which the master runs,
Kubernetes will not come up automatically.

To do so, you need to:
```
sudo systemctl restart containerd
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```