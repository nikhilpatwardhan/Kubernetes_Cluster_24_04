# Kubeadm (final setup)
Let's start with installing kubeadm as described below:
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/


Download the images and verify
```
sudo kubeadm config images pull --cri-socket unix:///var/run/containerd/containerd.sock
sudo crictl images
```

Ready to pull the trigger
```
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/containerd/containerd.sock --v=5
```

Output is
```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.12.1.12:6443 --token cwgrzd.kxkeotbdw27wjcht \
	--discovery-token-ca-cert-hash sha256:242584fa517a6788289e6703f829189d377c9444c44a7ee63de66e8d8bda1881
```

> [!NOTE]
> Save this token and the hash. But if you don't there is a way to discover them later too.

Execute the instructions above (as regular user)
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Then
```
nikhil@k8smaster:~$ kubectl get nodes
NAME        STATUS     ROLES           AGE     VERSION
k8smaster   NotReady   control-plane   2m19s   v1.33.3
```

To fix this, run the below.
Do not use sudo for the command below.
```
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
```

### Next Step
The cluster should now be ready to use. You can run queries, or add worker nodes, etc. Do Kubernetes stuff basically. Enjoy.

To shut down the machine run ```sudo shutdown now```, but remember that on reboot kubernetes will not be on. See the ![reboot script](./master_step_reboot.README.md).

```
wget --no-cache https://raw.githubusercontent.com/nikhilpatwardhan/Kubernetes_Cluster_24_04/refs/heads/main/reboot.sh
chmod +x reboot.sh
sudo ./reboot.sh
```
