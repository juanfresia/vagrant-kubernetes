#! /bin/bash

set -exuo

# Setup directory to stash stuff
## This should be shared among all the nodes
CACHE_DIR=/vagrant/cache
mkdir -p ${CACHE_DIR}

echo "Installing control plane node"

# un-hardcode IP and node name
kubeadm init --config=/vagrant/kubeadm-config.yaml --upload-certs \
    | tee ${CACHE_DIR}/kubeadm-init.out

## Setup kubeconfig (for root)
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

## Setup kubeconfig (for vagrant user)
TARGET_USER=vagrant
mkdir -p /home/${TARGET_USER}/.kube
cp -i /etc/kubernetes/admin.conf /home/${TARGET_USER}/.kube/config
chown $(id -u ${TARGET_USER}):$(id -g ${TARGET_USER}) /home/${TARGET_USER}/.kube/config

## Also save it to the cache
cp -i /etc/kubernetes/admin.conf ${CACHE_DIR}/admin.conf

## Install Calico (save applied .yaml for debugging)
wget -O ${CACHE_DIR}/calico.yaml https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f ${CACHE_DIR}/calico.yaml

## Configure nice kubectl
apt-get install bash-completion -y
source <(kubectl completion bash) && \
    echo "source <(kubectl completion bash)" >> $HOME/.bashrc

## Create a token to allow workers to join
### This files is stored in a shared cache, so worker nodes should be able to use it.
kubeadm token create --print-join-command > ${CACHE_DIR}/cluster-join.sh
chmod +x ${CACHE_DIR}/cluster-join.sh

true

