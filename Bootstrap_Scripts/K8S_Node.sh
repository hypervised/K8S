#Kubernetes node bootstrap script
#run syntax is sudo sh K8S_Node.sh <k8s version number>
#example sudo sh K8S_Node.sh 1.16.3
#dont forget to run sudo chmod 555 K8S_Node.sh
#!/bin/bash
sudo swapoff -a
sudo sed -i -e 's/enforcing/disabled/g' /etc/selinux/config;  setenforce 0
sudo yum install docker
sudo /bin/bash -c "cat > /etc/yum.repos.d/kubernetes.repo << EOM
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM"
yum update -y
yum -y install docker; systemctl enable docker; systemctl start docker
sudo yum install -y kubelet-$1; sudo systemctl enable kubelet; sudo systemctl start kubelet
sudo yum install -y kubectl-$1
sudo yum install -y kubeadm-$1
sudo /bin/bash -c "cat > /etc/sysctl.d/k8s.conf << EOM
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOM"
sudo sysctl --system
systemctl daemon-reload; sudo systemctl restart kubelet
