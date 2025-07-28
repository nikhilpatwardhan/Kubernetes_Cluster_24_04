## Goal
- To run a small Kubernetes cluster with just one master node and a handful or worker nodes, and do it all on virtual machines running on a home server.
- Partially automate the process of setting up a brand new virtual machine to be used as a master or worker node.

There are a bunch of installations and configurations to be done.
It would be nice to have a machine image that can be replicated, but as yet I haven't found a convenient way to do that. That is left for future.

Overall the steps we are following are those documented in
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/
- https://github.com/containerd/containerd/blob/main/docs/getting-started.md
- https://github.com/containerd/containerd/releases

### Environment
Truenas Fangtooth on a home server with dual E5-2620 6-core Xeon processors and around 300 GB of DDR3 RAM.

### Target state
- 1 Master node @ `10.12.1.12`
- 1 Worker node @ `10.12.1.13`
- 1 Worker node @ `10.12.1.14`