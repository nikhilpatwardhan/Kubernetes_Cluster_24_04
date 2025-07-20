# Create a master node in a Kubernetes cluster

## Goal
Automate part of the process of setting up a brand new machine as a master node in a k8s cluster.

There are lots of installations and configurations to be done.
It would be nice to have a machine image that can be replicated, but as yet I haven't found a way to do that. That is left for future.

## Platform
I'm running Truenas Fangtooth on a home server with 2 old Xeon processors and lots or RAM.

Create an instance (VM) with Ubuntu Server 24.04 LTS as the starting point.

> A ZVol is not necessary to install the OS.

Download the Ubuntu Server 24.04 LTS Live Server ISO image from the internet and upload it to Truenas as a Volume. When creating a new instance, choose this uploaded volume.
 
Create the VM with
- 2 CPU
- 8 GiB RAM
- 10 GiB Root Disk
- Select the appropriate NIC
- Setup a VNC port of 5901 (so that it does not clash with 5900 already in use)

Once the VM has started, use a VNC viewer (Screen Sharing app on iMac) to login to the machine at vnc://10.12.1.10:5901

(From the VNC window)
- Begin the Ubuntu installation process
- Choose the minimized option
- Choose the OpenSSH option at the end and import your public ssh key from github.com
- Complete the OS installation and reboot
- After reboot, first stop the running instance from Truenas
- Delete the Ubuntu Server 24.04 LTS volume
- Unselect Autostart
- Start the instance and take note of which IP address it has started up at (either by logging in from VNC and running ```ip a``` or from your router)
- SSH into the machine using that IP address
- Verify that swap space is off
```
nikhil@k8smaster:~$ free -m
               total        used        free      shared  buff/cache   available
Mem:            7929         513        6905           4         826        7416
Swap:              0           0           0
```

Initially, ipv4 forwarding is off
```
nikhil@k8smaster:~$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 0
nikhil@k8smaster:~$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
> net.ipv4.ip_forward = 1
> EOF
net.ipv4.ip_forward = 1
sudo sysctl --system
```

Check which cgroup driver is being used on the system
```
nikhil@k8smaster:~$ stat -fc %T /sys/fs/cgroup/
cgroup2fs
```

```ip a``` will also show you the MAC address, which you can then use to setup a DHCP reservation in the router to assign a static IP address e.g. 10.12.1.12 to this MAC address. Restart both the router and the VM to take effect. Verify by running ```ip a``` again.
