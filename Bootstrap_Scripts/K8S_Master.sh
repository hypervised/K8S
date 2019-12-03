#Kubernetes node bootstrap script
#run syntax is sudo sh K8S_Node.sh <k8s version number> <Master DNS name> <Master public IP>
#example sudo sh K8S_Node.sh 1.13.0
#dont forget to run sudo chmod 555 K8S_Node.sh
#!/bin/bash
H= echo "printenv | grep HOME | sed 's/HOME=//'"
sudo swapoff -a
sudo sed -i -e 's/enforcing/disabled/g' /etc/selinux/config;  setenforce 0
/bin/bash -c "cat > /etc/yum.repos.d/virt7-docker-common-release.repo << EOM
[virt7-docker-common-release]
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os/
gpgcheck=0
EOM"
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
sysctl --system
systemctl daemon-reload; sudo systemctl restart kubelet
sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-bind-port 443 --apiserver-cert-extra-sans=$2,$3 --ignore-preflight-errors=ALL --kubernetes-version=v$1 > /tmp/kubeadm.log
sudo mkdir -p  $H.kube
sudo cp -i /etc/kubernetes/admin.conf $H.kube/config
sudo chown $(id -u):$(id -g) $H.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml
grep 'kubeadm join' /tmp/kubeadm.log > $H.kube/join
sudo sed 's/server: .*$/server: https:\/\/'$3':443/' /etc/kubernetes/admin.conf | tee ~/.kube/Cluster.conf
