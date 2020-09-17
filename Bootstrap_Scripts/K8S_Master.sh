#!/bin/bash -e
#Kubernetes Master bootstrap script
#run syntax is  sudo /bin/bash K8S_Master.sh <k8s version number> <Master DNS name> <Master public IP>
#example  sh K8S_Node.sh 1.16.3 master.example.local 1.2.3.4
#dont forget to run  chmod 555 K8S_Master.sh
 swapoff -a
 sed -i -e 's/enforcing/disabled/g' /etc/selinux/config;   setenforce 0
sudo yum install docker
 /bin/bash -c "cat > /etc/yum.repos.d/kubernetes.repo << EOM
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM"
 yum update -y
 yum -y install docker;  systemctl enable docker;  systemctl start docker
 yum install -y kubelet-$1;  systemctl enable kubelet;  systemctl start kubelet
 yum install -y kubectl-$1
 yum install -y kubeadm-$1
 /bin/bash -c "cat > /etc/sysctl.d/k8s.conf << EOM
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOM"
 sysctl --system
 systemctl daemon-reload;  systemctl restart kubelet
 kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-bind-port 443 --apiserver-cert-extra-sans=$2,$3 --ignore-preflight-errors=ALL --k$
 sudo cp /etc/kubernetes/admin.conf $HOME/
 sudo chown $(id -u):$(id -g) $HOME/admin.conf
 export KUBECONFIG=$HOME/admin.conf
 kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
 sed 's/server: .*$/server: https:\/\/'$3':443/' /etc/kubernetes/admin.conf | tee /etc/kubernetes/Public-Cluster.conf
