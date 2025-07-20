Execute these steps manually

Open the default config file /etc/containerd/config.toml as sudo in vim and then add the SystemdCgroup option into this section
```
[plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc]
  ...
  [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.runc.options]
    SystemdCgroup = true
```

```
sudo vim /etc/containerd/config.toml
```

Then run
```
sudo systemctl restart containerd
```
