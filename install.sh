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
VERSION="0.2.0"


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

echo -e "[$GREEN+$RESET] This script will install the required tools to run recon.sh, please stand by..";
echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)";
sleep 1;
echo -e "[$GREEN+$RESET] Getting the basics..";
sudo apt-get update -y;
#sudo apt-get upgrade -y; #turned off for dev, maybe not needed at all. Would improve the speed of the script

echo -e "[$GREEN+$RESET] Installing and setting up Go..";
cd $HOME;
wget https://dl.google.com/go/go1.10.3.linux-armv6l.tar.gz; # takes a long time but does get a LOT of good dependencies
sudo tar -xvf go1.10.3.linux-armv6l.tar.gz;
echo -e "[$GREEN+$RESET] Creating directories..";
mv go go1.10;
mkdir -p tools;
mkdir -p go;
echo -e "[$GREEN+$RESET] Done.";
sudo chmod u+w .;
# set export crap right
echo -e 'export GOPATH=$HOME/go' >> ~/.profile;
echo -e 'export GOROOT=$HOME/go1.10' >> ~/.profile;
#echo -e 'export PATH=$PATH:$GOPATH' >> ~/.profile;
#echo -e 'export PATH=$PATH:$GOROOT/bin' >> ~/.profile;
source ~/.profile;
go version;
go env;
# extra dependencies, beautify later
#sudo apt-get install -y ruby; #doesn't work, needs RVM
#RVM:
echo -e "[$GREEN+$RESET] Installing and setting up RVM..";
sudo apt-get install software-properties-common;
sudo apt-add-repository -y ppa:rael-gc/rvm;
sudo apt-get update;
sudo apt-get install rvm;
source /etc/profile.d/rvm.sh;
sudo usermod -a -G rvm ubuntu;
echo -e "[$GREEN+$RESET] First part of the installation is complete.";
echo -e "[$GREEN+$RESET] The script will now logout, please use ./install2.sh to continue the installation!";
echo -e "[$GREEN+$RESET] Logout in 5 seconds..";
displayLogo;
sleep 5;
echo -e "[$GREEN+$RESET] First script finished! Please login again and start install2.sh";
logout;
# Script needs to do logout because of all the changes