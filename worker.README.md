## Running a Kubernetes worker node

### Pre-requisite
The initial setup is identical to that of setting up a master node. Follow all the steps upto ![installing kubelet](./master_step_3.sh).

### Join the cluster
When the master node is initialized, it would have generated a token and a hash. You will need that along with the IP address of the master node.

Just make sure that kubelet is running (if the worker was restarted). Post-restart steps are identical to ![restarting the master](./master_step_reboot.README.md).

```
kubeadm join 10.12.1.12:6443 --token cwgrzd.kxkeotbdw27wjcht --discovery-token-ca-cert-hash sha256:242584fa517a6788289e6703f829189d377c9444c44a7ee63de66e8d8bda1881 --v=5
```

Once it has joined successfully you will see it on the master node
```
nikhil@master1:~$ kubectl get nodes --all-namespaces
NAME            STATUS   ROLES           AGE     VERSION
master1.local   Ready    control-plane   23m     v1.33.3
worker1.local   Ready    <none>          9m37s   v1.33.3
```

If you shutdown the worker, after a while it will no longer show up in the master node
```
nikhil@master1:~$ kubectl get nodes --all-namespaces
NAME            STATUS     ROLES           AGE   VERSION
master1.local   Ready      control-plane   31m   v1.33.3
worker1.local   NotReady   <none>          17m   v1.33.3
```
