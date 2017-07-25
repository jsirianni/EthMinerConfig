# Ubuntu 16.04 Eth mining prep
# v1.0

# Run updates and install packages
apt-get update
apt-get dist-upgrade -y
apt-get install htop iotop nmap fail2ban vim nano wget curl -y
apt-get install tree rsync unzip bash-completion net-tools screen  -y

# Install netdata
bash <(curl -Ss https://my-netdata.io/kickstart.sh)


# Get AMD driver
wget --referer=http://support.amd.com https://www2.ati.com/drivers/linux/ubuntu/amdgpu-pro-17.10-414273.tar.xz
tar -Jxvf amdgpu-pro-17.10-414273.tar.xz
cd amdgpu-pro-17.10-414273
./amdgpu-pro-install -y
usermod -a -G video $LOGNAME


# Install Eth miner
wget https://github.com/nanopool/Claymore-Dual-Miner/releases/download/v9.5/Claymore.s.Dual.Ethereum.Decred_Siacoin_Lbry_Pascal.AMD.NVIDIA.GPU.Miner.v9.5.-.LINUX.tar.gz
mkdir /usr/local/claymore95
tar -xvf Claymore.s.Dual.Ethereum.Decred_Siacoin_Lbry_Pascal.AMD.NVIDIA.GPU.Miner.v9.5.-.LINUX.tar.gz -C /usr/local/claymore95
chmod u+x /usr/local/claymore95/ethdcrminer64

# Configure miner
touch /usr/local/claymore95/mine.sh
echo "#!/bin/sh" >> /usr/local/claymore95/mine.sh
echo "export GPU_MAX_ALLOC_PERCENT=100" >> /usr/local/claymore95/mine.sh
echo "./ethdcrminer64 -epool us1.ethermine.org:4444 -ewal 0xc070baab1abd0053ebde19d301b9c42f62668887.minerTest -epsw x -mode 1 -tt 68 -allpools 1" >> /usr/local/claymore95/mine.sh
chmod +x /usr/local/claymore95/mine.sh

# Configure auto launch
touch ~/miner_launcher.sh
echo "#!/bin/bash" >> ~/miner_launcher.sh
echo "DEFAULT_DELAY=0" >> ~/miner_launcher.sh
echo "if [ "x$1" = "x" -o "x$1" = "xnone" ]; then" >> ~/miner_launcher.sh
echo "   DELAY=$DEFAULT_DELAY" >> ~/miner_launcher.sh
echo "else" >> ~/miner_launcher.sh
echo "   DELAY=$1" >> ~/miner_launcher.sh
echo "fi" >> ~/miner_launcher.sh
echo "sleep $DELAY" >> ~/miner_launcher.sh
echo "cd /usr/local/claymore95" >> ~/miner_launcher.sh
echo "su teamit -c "screen -dmS ethm ./mine.sh"" >> ~/miner_launcher.sh
chmod +x ~/miner_launcher.sh

# Configure rc.local autostart
rm /etc/rc.local
touch /etc/rc.local
echo "/home/teamit/miner_launcher.sh 15 &" >> /etc/rc.local
echo "exit 0" >> /etc/rc.local

# Configure bashrc
echo "alias miner='screen -x ethm'" >> ~/.bashrc

# Reboot
shutdown -r now
