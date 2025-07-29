## Goal
- To run a small Kubernetes cluster with just one master node and a handful or worker nodes, and do it all using virtual machines running on a home server (Truenas) and home LAN.
- Partially automate the process of setting up a brand new virtual machine to be used as a master or worker node.
- Use a simple CNI plugin (Flannel).

Overall, the steps are from:
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://github.com/containerd/containerd/blob/main/docs/getting-started.md
- https://github.com/containerd/containerd/releases

### Environment
Truenas Fangtooth (25.04) on a home server with dual E5-2620 6-core Xeon processors and around 300 GB of DDR3 RAM.

### Target state
- 1 Master node @ `10.12.1.12`
- 1 Worker node @ `10.12.1.13`
- 1 Worker node @ `10.12.1.14`

### Steps
Start with setting up the ![master](./master_step_0.README.md) and proceed to the other files in sequential order. Then, proceed to the ![worker](./worker.README.md).