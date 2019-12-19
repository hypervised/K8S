#Docker node bootstrap script
#run syntax is sudo /bin/bash/Docker_Node.sh
#dont forget to run sudo chmod 555 Docker_Node.sh
#!/bin/bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce
sudo useradd whale
sudo usermod -aG docker whale
sudo systemctl restart docker
sudo systemctl enable docker
docker run hello-world
