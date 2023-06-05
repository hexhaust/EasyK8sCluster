#!/bin/bash

#Cria a configuração para o Containerd
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

#Load modules:
sudo modprobe overlay
sudo modprobe br_netfilter

#Setando a config de sistema para redes:
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

#Aplicando as configs
sudo sysctl --system

#Instalando containerd
sudo apt update && sudo apt upgrade -y && sudo apt install containerd -y

#Criando arquivo de config para o containerd
sudo mkdir -p /etc/containerd

#Criando configuração default para o containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml

#Restart restart do containerd depois de instalar
sudo systemctl restart containerd

#Desabilitando o swap:
sudo swapoff -a

#Instalando deps
sudo apt update -y && sudo apt install -y apt-transport-https curl
#Baixando e adicionando a GPGkey
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
#Adicionando o k8s a lista de repos
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

#Atualizando lista de pacotes
sudo apt update -y && sudo apt upgrade -y
#Ins[talando packs do Kubernetes [setei o sleep pra evitar o dpkg-lock]
sleep 60
sudo apt-get install -y kubelet=1.25.0-00 kubeadm=1.25.0-00 kubectl=1.25.0-00
#Desabilitar atualizaçoes automaticas
sudo apt-mark hold kubelet kubeadm kubectl
