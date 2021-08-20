# Sandbox environment for CKA practice on Vagrant

This repo contains scripts and configuration files needed to bring up a cluster
of virtual machines with a running Kubernetes cluster (1 control plane node, 2
worker nodes; scalable).

Use `config.yaml` to decide how many machines will be brought up. Keep in mind
that we currently support one control plane node.

## Pre-requisites

You will need:
- [Vagrant](https://www.vagrantup.com/downloads.html) (tested with 2.2.18)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (tested with 6.1.2
  r145957)
- Vagrant vbguest plugin (can be installed with `vagrant plugin install
  vagrant-vbguest`)

## Using this repository

As per this configuration, each machine will be named `node-X` where `node-1` is
the control plane node. `node-2` and `node-3` will be worker nodes and any other
one will get an incremental ID.

The IPs of the nodes are stated in the `config.yaml` and also refrenced in
`provision.sh`. They are within the 10.0.0.0/24 range.

The Pods IP range is configured by default to `192.168.0.0/16`. The cluster is
deployed with Calico as the network provider, and the range was selected to
match it's defaults.

### Bringing up the cluster

Run `vagrant up` to bring up the cluster. The first time it will take some time
creating the VMs and provisioning them.

The `provision.sh` script will be run for all machines, while the `master.sh`
and `worker.sh` scripts will run only in the machines with that role (as stated
in the `config.yaml` file. Feel free to change those to add/remove
configurations.

### Pausing the cluster

Run `vagrant halt` to shut down all machines without deleting it. You can also
halt a single machine by using the host name.

### Accessing the cluster

Run `vagrant status` to get see which virtual machines are currently running.

Run `vagrant ssh node-x` to ssh into the machine x.

### Destroying the cluster

**WARNING**: This will permanently delete all the nodes and their data.

Run `vagrant destroy` to permanently delete all virtual machines. You'll be
prompted to confirm deletion for each of them. Alternativelly you can delete a
signle machine using its host name.

### Sharing files with host system

Vagrant virtual machines share with the host the directory where
the Vagrantfile is. This direcotry is mounted in `/vagrant` on every VM.
