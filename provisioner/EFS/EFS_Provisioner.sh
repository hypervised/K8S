#!/bin/bash -e
#Attach EFS to K8S / microk8s
#run syntax is  sudo /bin/bash EFS_Provisioner.sh <EFS DNS Name> <EFS File System ID> <region>
#example  sudo sh EFS_Provisioner.sh fs-12345678.efs.us-east-1.amazonaws.com fs-12345678 us-east-1
#dont forget to run  chmod 555 EFS_Provisioner.sh
#$1=DNS name of EFS, example fs-12345678.efs.us-east-1.amazonaws.com
#$2= The file system id for efs, example fs-12345678
#$3= the region the EFS is located in

#install nfs tools and mount the file system
sudo apt install -yqq nfs-common
sudo mkdir efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 $1:/ efs

#get manifests
wget https://raw.githubusercontent.com/hypervised/K8S/master/provisioner/EFS/claim.yaml > claim.yaml
wget https://raw.githubusercontent.com/hypervised/K8S/master/provisioner/EFS/class.yaml > class.yaml
wget https://raw.githubusercontent.com/hypervised/K8S/master/provisioner/EFS/configmap.yaml > configmap.yaml
wget https://raw.githubusercontent.com/hypervised/K8S/master/provisioner/EFS/deployment.yaml > deployment.yaml
wget https://raw.githubusercontent.com/hypervised/K8S/master/provisioner/EFS/rbac.yaml > rbac.yaml
wget https://raw.githubusercontent.com/hypervised/K8S/master/provisioner/EFS/test-pod.yaml > test-pods.yaml

#update the yaml files with your EFS info
sudo sed -i '/dns.name:/s/REPLACEDNAME/$1/g' configmap.yaml
sudo sed -i '/file.system.id:/s/REPLACEFSID/$2/g' configmap.yaml
sudo sed -i '/dns.name:/s/REPLACEREGION/$3/g' configmap.yaml
sudo sed -i '/server:/s/REPLACESERVER/$1/g' deployment.yaml

#deploy the manifests

sudo microk8s.kubectl apply -f class.yaml
sudo microk8s.kubectl apply -f configmap.yaml
sudo microk8s.kubectl apply -f rbac.yaml
sudo microk8s.kubectl apply -f deployment.yaml
sudo microk8s.kubectl apply -f claim.yaml
sudo microk8s.kubectl apply -f test-pod.yaml
