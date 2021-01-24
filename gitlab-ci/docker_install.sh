sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y mc docker-ce docker-compose

sudo mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
sudo cp /tmp/docker-compose.yml /srv/gitlab/docker-compose.yml
cd /srv/gitlab
export EXTERNAL_IP=$(curl ifconfig.io)
sudo sed -i 's/35.233.79.168/'$EXTERNAL_IP'/g' docker-compose.yml
echo $EXTERNAL_IP
sudo usermod -aG docker $USER