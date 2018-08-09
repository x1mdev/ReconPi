#!/bin/bash
: '
	@name   ReconPi install.sh
	@author Martijn Baalman <@x1m_martijn>
	@link   https://github.com/x1mdev/ReconPi
'


: 'Set the main variables'
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RESET="\033[0m"
VERSION="0.2.1"


: 'Display the logo'
displayLogo()
{
	echo -e "
__________                          __________.__
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/
                          v$VERSION - by $YELLOW@x1m_martijn$RESET
	"
}

displayLogo;

echo -e "[$GREEN+$RESET] This is the install script that will install the required dependencies to run recon.sh, please stand by..";
echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)";
sleep 1;
echo -e "[$GREEN+$RESET] Getting the basics..";
sudo apt-get install git -y;
sudo apt-get update -y;
sudo apt-get upgrade -y;
# You can choose to comment out the `sudo apt-get upgrade` line for speed. NOT advised tho

echo -e "[$GREEN+$RESET] Installing and setting up Go..";
cd "$HOME" || return;
wget https://dl.google.com/go/go1.10.3.linux-armv6l.tar.gz;
sudo tar -xvf go1.10.3.linux-armv6l.tar.gz;
echo -e "[$GREEN+$RESET] Creating directories..";
mv go go1.10;
mkdir -p tools;
mkdir -p go;
git clone https://github.com/x1mdev/ReconPi.git;
echo -e "[$GREEN+$RESET] Done.";
sudo chmod u+w .;
echo -e 'export GOPATH=$HOME/go' >> $HOME/.bashrc;
echo -e 'export GOROOT=$HOME/go1.10' >> $HOME/.bashrc;
echo -e 'export PATH=$PATH:$GOPATH' >> $HOME/.bashrc;
echo -e 'export PATH=$PATH:$GOROOT/bin' >> $HOME/.bashrc;
source $HOME/.bashrc;
go version;
go env;
cd $HOME/tools/  || return;

echo -e "[$GREEN+$RESET] Installing Node & NPM..";
sudo apt-get install -y npm;
sudo apt-get install -y nodejs-legacy;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Subfinder..";
go get github.com/subfinder/subfinder;
sudo cp $HOME/go/bin/subfinder /usr/local/bin/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing massdns..";
cd $HOME/tools/ || return;
git clone https://github.com/blechschmidt/massdns.git;
cd massdns;
echo -e "[$GREEN+$RESET] Running make command for massdns..";
make;
sudo cp "$HOME/tools/massdns/bin/massdns /usr/local/bin/";
sudo apt-get install jq;
cd $HOME/tools/ || return;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing teh_s3_bucketeers..";
git clone https://github.com/tomdev/teh_s3_bucketeers.git;
cd $HOME/tools/ || return;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing virtual host discovery..";
git clone https://github.com/jobertabma/virtual-host-discovery.git;
cd $HOME/tools/ || return;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing nmap..";
sudo apt-get install -y nmap;
cd $HOME/tools/ || return;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Echo framework (GO)..";
go get -u github.com/labstack/echo;
go get github.com/GeertJohan/go.rice;

echo -e "[$GREEN+$RESET] Installing Nginx..";
sudo apt-get install -y nginx;
sudo nginx -t;
cd $HOME/tools/  || return;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Cleaning up..";
displayLogo;
cd $HOME || return;
rm go1.10.3.linux-armv6l.tar.gz;
rm install.sh; 
echo -e "[$GREEN+$RESET] Installation script finished! System will reboot to finalize installation.";
sleep 1;
sudo reboot;