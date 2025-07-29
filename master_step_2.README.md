Execute these steps manually

```
sudo vim /etc/containerd/config.toml
```

Open the default config file `/etc/containerd/config.toml` as `sudo` in `vim` and then add the `SystemdCgroup` option into the section shown below.
```
[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc]
  ...
  [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
    SystemdCgroup = true
```

Then run
```
sudo systemctl restart containerd
```

### Next Step
```
wget --no-cache https://raw.githubusercontent.com/nikhilpatwardhan/Kubernetes_Cluster_24_04/refs/heads/main/master_step_3.sh
chmod +x master_step_3.sh
sudo ./master_step_3.sh
```