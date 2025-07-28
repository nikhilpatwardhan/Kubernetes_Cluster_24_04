# Create a master node in a Kubernetes cluster
 
### Create the VM (i.e. instance)
Create an instance (VM) with Ubuntu Server 24.04 LTS as the starting image using the Truenas GUI in the Instances section. [https://releases.ubuntu.com/noble/ubuntu-24.04.2-desktop-amd64.iso]

> [!NOTE]
> A ZVol is not necessary to install the OS. Just install it into the Root disk.

Download the Ubuntu Server 24.04 LTS Live Server ISO image from the internet and upload it to Truenas as a Volume. When creating a new instance, choose this uploaded volume.

For this setup, I have chosen a modest spec for each machine in the New Instance creation GUI in Truenas as follows:
- 2 CPU
- 8 GiB RAM
- 10 GiB Root Disk
- Select the appropriate NIC
- Setup a VNC port of 5901 (or some other port so that it does not clash with 5900 already in use)

Once the VM has started, use a VNC viewer (Screen Sharing app on iMac) to login to the machine at `vnc://10.12.1.10:5901`. Note that this is the IP address of truenas.

### Installation
From the VNC window:
- Begin the Ubuntu installation process
  - Choose the minimized option
  - Choose the OpenSSH option at the end and import your public ssh key from github.com
- Complete the OS installation and reboot
- After reboot:
  - Stop the running instance from Truenas
  - Delete the Ubuntu Server 24.04 LTS **disk** _from this instance only_ ![](assets/delete_disk.png)
  - Unselect Autostart
  - Start the instance and take note of which IP address it has started up at (either by logging in from VNC and running ```ip a``` or from your router)
  - SSH into the machine using that IP address

### Checks
On logging in to the machine, verify a few things:

1. swap space is off
```
nikhil@k8smaster:~$ free -m
               total        used        free      shared  buff/cache   available
Mem:            7929         513        6905           4         826        7416
Swap:              0           0           0
```

2. ipv4 forwarding is off (it will be turned on by our script)
```
nikhil@k8smaster:~$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 0
```

3. The cgroup driver used on the system is `cgroup2fs`
```
nikhil@k8smaster:~$ stat -fc %T /sys/fs/cgroup/
cgroup2fs
```

### Assign a hostname
For convenience, set a hostname on the machine (e.g. `master1.local` for the master node, `worker1.local` for the first worker, and so on):
```
sudo hostnamectl set-hostname master1.local
```

### Assign a static IP
```ip a``` will also show you the MAC address of this host, which you can then use to setup a DHCP reservation in the router to assign a static IP address.

Here, we are going to assign the following static IPs
##### Master
`10.12.1.12`
##### Worker1
`10.12.1.13`
##### Worker2
`10.12.1.14`

Reboot the VM, and also reboot the router.
```
sudo reboot now
```

### Next Step
To run the ```master_step_1.sh``` file after SSH'ing in:
```
wget https://raw.githubusercontent.com/nikhilpatwardhan/Kubernetes_Cluster_24_04/refs/heads/main/master_step_1.sh
chmod +x master_step_1.sh
sudo ./master_step_1.sh
```