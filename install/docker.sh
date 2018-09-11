# 安装docker需要翻墙，如果是虚拟机可以直接在linux系统装翻墙工具，
# 也可以安装宿主机上，然后通过虚拟机通过NAT方式进行网络连接

# remove old docker
sudo apt-get remove docker docker-engine docker.io

sudo apt-get update

#depend tools
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

#Add Docker’s official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# add source to source.list
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

#install docker
sudo apt-get install docker-ce
