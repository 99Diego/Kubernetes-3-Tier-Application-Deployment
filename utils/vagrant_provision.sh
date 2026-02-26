#!/bin/bash

sudo apt-get update

# Docker Installation
if [[ ! -x "$(command -v docker)" ]]; then
  sudo apt-get --yes install \
      apt-transport-https \
      ca-certificates \
      curl \
      gnupg \
      lsb-release \
      jq

  curl -fsSL https://download.docker.com/linux/debian/gpg | \
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get --yes install docker-ce docker-ce-cli containerd.io

  sudo groupadd docker
  sudo usermod -aG docker "${USER}"

  sudo systemctl enable docker.service
  sudo systemctl enable containerd.service

  sudo systemctl start docker.service
  sudo systemctl start containerd.service
fi

# Hadolint Installation
if [[ ! -f "/usr/local/bin/hadolint" ]]; then
  curl -LO https://github.com/hadolint/hadolint/releases/download/v2.7.0/hadolint-Linux-x86_64
  sudo install hadolint-Linux-x86_64 /usr/local/bin/hadolint
  rm -f hadolint-Linux-x86_64
fi

# Kubectl Installation
if [[ ! -f "/usr/local/bin/kubectl" ]]; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm -f kubectl
  echo 'source <(kubectl completion bash)' >>~/.bashrc
fi

# Minikube Installation
if [[ ! -f "/usr/local/bin/minikube" ]]; then
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm -f minikube-linux-amd64
fi
