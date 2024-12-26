apt install software-properties-common -y
echo -e "\n" | sudo add-apt-repository -y ppa:deadsnakes/ppa
apt install python3-pip -y
pip install ansible 
export PATH=$PATH:/usr/bin

ansible --version
