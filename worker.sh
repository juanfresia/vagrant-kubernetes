#!/bin/bash

set -exuo

# Setup directory to stash stuff
## This should be shared among all the nodes
CACHE_DIR=/vagrant/cache

## Attempt to join
# ${CACHE_DIR}/cluster-join.sh

## Setup kubeconfig (as root)
mkdir -p $HOME/.kube
cp -i ${CACHE_DIR}/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

## Setup kubeconfig (as user vagrant)
TARGET_USER=vagrant
mkdir -p /home/${TARGET_USER}/.kube
cp -i ${CACHE_DIR}/admin.conf /home/${TARGET_USER}/.kube/config
chown $(id -u ${TARGET_USER}):$(id -g ${TARGET_USER}) /home/${TARGET_USER}/.kube/config

