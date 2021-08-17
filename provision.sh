#! /bin/bash

set -exuo

# We are in an Ubuntu 18.04, update distribution
apt-get update && apt-get upgrade -y

# Install useful dev packages
apt-get install -y vim

# Install Docker CE
## Following: https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

### Add Docker apt repository.
echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | tee /etc/apt/sources.list.d/docker.list > /dev/null

## Update repository and install docker
apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io

# Setup docker daemon as recommended by k8s: https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
cat > /etc/docker/daemon.json <<-EOF
	{
		"exec-opts": ["native.cgroupdriver=systemd"],
		"log-driver": "json-file",
		"log-opts": {
			"max-size": "100m"
		},
		"storage-driver": "overlay2"
	}
	EOF
mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker


# Istall kubernetes tooling

## Install kubernetes apt repository
echo "deb  http://apt.kubernetes.io/  kubernetes-xenial  main" | tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

## Install kubernetes pacakges
apt-get update && apt-get install -y kubeadm=1.20.1-00 kubelet=1.20.1-00 kubectl=1.20.1-00
apt-mark hold kubelet kubeadm kubectl


### The setup most continue differently depending if we are in the master or in the node
if [[ "${NODE_ROLE}" == "master" ]]; then
    /vagrant/master.sh
    exit 0
fi

if [[ "${NODE_ROLE}" == "worker" ]]; then
    /vagrant/worker.sh
    exit 0
fi
