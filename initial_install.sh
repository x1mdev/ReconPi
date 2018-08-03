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

echo -e "[$GREEN+$RESET] This is the first script that will install the required dependencies to run recon.sh, please stand by..";
echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)";
sleep 1;
echo -e "[$GREEN+$RESET] Getting the basics..";
echo -e 'export LC_ALL="en_US.UTF-8"' >> $HOME/.bashrc;
echo -e 'export LC_CTYPE="en_US.UTF-8"' >> $HOME/.bashrc;
source $HOME/.bashrc;
sudo apt-get install git -y;
sudo apt-get update -y;
#sudo apt-get upgrade -y; #turned off for dev, maybe not needed at all. Would improve the speed of the script

echo -e "[$GREEN+$RESET] Installing and setting up Go..";
cd "$HOME" || return;
wget https://dl.google.com/go/go1.10.3.linux-armv6l.tar.gz; # takes a long time but does get a LOT of good dependencies
sudo tar -xvf go1.10.3.linux-armv6l.tar.gz;
echo -e "[$GREEN+$RESET] Creating directories..";
mv go go1.10;
mkdir -p tools;
mkdir -p go;
# clone ReconPi repo because stretch lite lacks git by default -.-
git clone https://github.com/x1mdev/ReconPi.git;
echo -e "[$GREEN+$RESET] Done.";
sudo chmod u+w .;
# set export crap right
echo -e 'export GOPATH=$HOME/go' >> $HOME/.bashrc;
echo -e 'export GOROOT=$HOME/go1.10' >> $HOME/.bashrc;
#echo -e 'export PATH=$PATH:$GOPATH' >> ~/.profile;
#echo -e 'export PATH=$PATH:$GOROOT/bin' >> ~/.profile;
source $HOME/.bashrc;
go version;
go env;
cd $HOME/tools/;

echo -e "[$GREEN+$RESET] Installing Node & NPM..";
sudo apt-get install -y npm;
sudo apt-get install -y nodejs-legacy;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Subfinder..";
go get github.com/subfinder/subfinder;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing snap..";
sudo apt-get install -y snap;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing amass..";
sudo snap install amass;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing teh_s3_bucketeers..";
git clone https://github.com/tomdev/teh_s3_bucketeers.git;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing virtual host discovery..";
git clone https://github.com/jobertabma/virtual-host-discovery.git;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing nmap..";
sudo apt-get install -y nmap;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing and setting up PHP..";
echo -e "[$GREEN+$RESET] SKIPPING";
# maybe not needed as php7.2 is default on ubuntu 18.04 
# PHP and Composer are used for the Laravel dashboard - maybe dockerize this? dockerize database only i guess if 7.2 is native on 18.04
#apt-get install -y python-software-properties;
#sudo add-apt-repository -y ppa:ondrej/php;
#sudo apt-get update;
#sudo apt-get install -y php7.2;
# if 18.04 uncomment this: (for later)
#sudo apt-get install -y php;
#php -v;
#sudo apt-get install -y php-pear php-fpm php-dev php-zip php-curl php-xmlrpc php-gd php-mysql php-mbstring php-xml libapache2-mod-php;
#sudo apt-get install -y composer;
#echo -e 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc
#source ~/.bashrc;
#composer global require "laravel/installer";
# REPLACE WITH DASHBOARD FROM OTHER REPO
#./.config/composer/vendor/bin/laravel new dashboard;
# ~/dashboard is the directory I  created a test laravel install
# git clone ReconPi Dashboard repo
#cd dashboard || return;
#composer update
#sudo chgrp -R www-data storage bootstrap/cache;
# sudo chgrp -R ubuntu storage bootstrap/cache;
#sudo chmod -R ug+rwx storage bootstrap/cache;
echo -e "[$GREEN+$RESET] Done.";

# extra dependencies, beautify later
#sudo apt-get install -y ruby; #doesn't work, needs RVM
#RVM:
echo -e "[$GREEN+$RESET] Installing and setting up RVM..";
echo -e "[$GREEN+$RESET] SKIPPING";
#sudo apt-get install -y software-properties-common;
#sudo apt-add-repository -y ppa:rael-gc/rvm;
#sudo apt-get update;
#sudo apt-get install -y rvm;
#source /etc/profile.d/rvm.sh;
#sudo usermod -a -G rvm ubuntu;
echo -e "[$GREEN+$RESET] First part of the installation is complete.";
#echo -e "[$GREEN+$RESET] The script will now logout, please use ./install2.sh to continue the installation!";
#echo -e "[$GREEN+$RESET] Logout in 5 seconds..";
displayLogo;
sleep 5;
echo -e "[$GREEN+$RESET] Initial script finished! Please login again and start second_install.sh";
sleep 1;
#logout;
# Script needs to do logout because of all the changes