# Kubeadm (final setup)
Let's start with installing kubeadm as described below:
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/


Verify that images are showing up
```
sudo crictl images
```

Ready to pull the trigger
```
sudo kubeadm init --pod-network-cidr=10.12.1.0/24 --cri-socket unix:///var/run/containerd/containerd.sock --v=5
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

kubeadm join 10.12.1.12:6443 --token wv5o1n.9ba16igxb5pigkv3 \
	--discovery-token-ca-cert-hash sha256:24527c68238e7640cd847337f9faf02e84794cd26fac6538748a84be1c22747f
```

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

nikhil@k8smaster:~$ sudo crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                                 NAMESPACE
7fcebd04735fb       af855adae7960       2 minutes ago       Running             kube-proxy                0                   3d42892e99a61       kube-proxy-7w4ht                    kube-system
0e629fc0e965d       bf97fadcef430       2 minutes ago       Running             kube-controller-manager   0                   f95d12f6767f3       kube-controller-manager-k8smaster   kube-system
24fde49521dda       a92b4b92a9916       2 minutes ago       Running             kube-apiserver            0                   b318bf8af9f20       kube-apiserver-k8smaster            kube-system
b3c376de8697b       41376797d5122       2 minutes ago       Running             kube-scheduler            0                   24595ce2dbddb       kube-scheduler-k8smaster            kube-system
f5fc7862bfb3d       499038711c081       2 minutes ago       Running             etcd                      0                   456b1ec2670c3       etcd-k8smaster                      kube-system
```

To fix this
```
kubectl apply -f https://github.com/antrea-io/antrea/releases/download/v2.4.0/antrea.yml
```

After this the ssh session closes and cannot be re-established. SSH is removed from the firewall rules, but that's ok because we can still connect to the machine from VNC where it shows that the master node is now Ready. You can then add back the ssh rule.

```
sudo ufw allow from 10.12.1.0/24 to any port 22
```
