#! /bin/bash

set -exuo

# Setup directory to stash stuff
CACHE_DIR=/vagrant/cache
mkdir -p ${CACHE_DIR}

echo "Installing control plane node"

# un-hardcode IP and node name
kubeadm init --config=kubeadm-config.yaml --upload-certs \
    | tee ${CACHE_DIR}/cache/kubeadm-init.out

## Setup kubeconfig
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

## Also save it to the cache
cp -i /etc/kubernetes/admin.conf ${CACHE_DIR}/admin.conf

## TODO: Install Calico and stuff

## Configure nice kubectl
apt-get install bash-completion -y
source <(kubectl completion bash) && \
    echo "source <(kubectl completion bash)" >> $HOME/.bashrc

## Create a token to allow workers to join
### This files is stored in a shared cache, so worker nodes should be able to use it.
kubeadm token create --print-join-command > ${CACHE_DIR}/cluster-join.sh
chmod +x ${CACHE_DIR}/cluster-join.sh

true

