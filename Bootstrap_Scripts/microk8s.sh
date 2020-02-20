#microk8s install script
#sudo apt-get install snap -y;
sudo snap install microk8s --classic;
sudo microk8s.status --wait-ready;
sudo microk8s.enable dns dashboard registry;
