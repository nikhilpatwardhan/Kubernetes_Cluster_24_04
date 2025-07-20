Prepping the master machine
6 GiB Root Disk
12 GiB Imported ZVol called d1

Started with a Ubuntu Server 24.04 (minimized) LTS image
No OpenSSH

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/


sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable —now ssh
sudo systemctl status ssh
sudo apt install net-tools
sudo apt install vim

Use the mac address shown by the command below to reserve the IP address. Restart the router and the machine to take effect. In this case the reserved addess is 10.12.1.12

ip a
00:16:3e:72:c1:e0

sudo apt install ufw
sudo ufw allow ssh
sudo ufw enable
sudo ufw status verbose
sudo ufw allow from 10.12.1.0/24 to any port 6443
sudo ufw allow from 10.12.1.0/24 to any port 10250
sudo ufw allow from 10.12.1.0/24 to any port 10259
sudo ufw allow from 10.12.1.0/24 to any port 10257
sudo ufw allow from 10.12.1.0/24 to any port 2379
sudo ufw allow from 10.12.1.0/24 to any port 2380

Verify that swap space is off
nikhil@k8smaster:~$ free -m
               total        used        free      shared  buff/cache   available
Mem:            7929         513        6905           4         826        7416
Swap:              0           0           0


https://kubernetes.io/docs/setup/production-environment/container-runtimes/

Initially, ipv4 forwarding is off
nikhil@k8smaster:~$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 0


nikhil@k8smaster:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.ipv4.ip_forward = 1
> EOF
net.ipv4.ip_forward = 1


sudo sysctl --system


Check which cgroup driver is being used on the system
nikhil@k8smaster:~$ stat -fc %T /sys/fs/cgroup/
cgroup2fs

https://github.com/containerd/containerd/blob/main/docs/getting-started.md

https://github.com/containerd/containerd/releases


containerd
wget https://github.com/containerd/containerd/releases/download/v2.1.3/containerd-2.1.3-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-2.1.3-linux-amd64.tar.gz

wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /lib/systemd/system
sudo systemctl start containerd

sudo apt install libseccomp2 libseccomp-dev

wget https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

wget https://github.com/containernetworking/plugins/releases/download/v1.7.1/cni-plugins-linux-amd64-v1.7.1.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.7.1.tgz

sudo mkdir -p /etc/containerd
sudo containerd config default|sudo tee /etc/containerd/config.toml

Add the SystemdCgroup option into
[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc]
  ...
  [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
    SystemdCgroup = true

sudo systemctl restart containerd


============
Let's start with installing kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/


sudo apt-get install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list


sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl


# Show the versions installed (they should all match, in this case 1.33)
kubeadm version
kubectl version
kubelet version

sudo crictl ps
sudo systemctl enable kubelet

# sudo vim /etc/crictl.yaml
# And enter the below contents
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: true # <- if you don't want to see debug info you can set this to false
pull-image-on-create: false

# Observe that the output is now different
sudo crictl ps


# These steps can happen earlier
sudo apt install systemd-timesyncd
sudo timedatectl set-ntp true
sudo timedatectl status

# These steps can happen earlier
# sudo vim /etc/modules-load.d/k8s.conf
# And enter the below contents
overlay
br_netfilter

sudo modprobe overlay
sudo modprobe br_netfilter


# Ok let's pull the Kubernetes images
sudo kubeadm config images pull --cri-socket unix:///var/run/containerd/containerd.sock

# Verify that images are showing up
sudo crictl images

# Ready!
sudo kubeadm init --pod-network-cidr=10.12.1.0/24 --cri-socket unix:///var/run/containerd/containerd.sock --v=5

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


# Execute the instructions above (normal user)
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

kubectl apply -f https://github.com/antrea-io/antrea/releases/download/v2.4.0/antrea.yml

After this the ssh session closes and cannot be re-established
However from VNC it shows that the master node is now Ready
