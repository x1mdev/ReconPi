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

echo -e "[$GREEN+$RESET] This script will continue to install the required tools to run recon.sh, please stand by..";
echo -e "[$GREEN+$RESET] It will take a while, go grab a second cup of coffee ;)";
sleep 1;

echo -e "[$GREEN+$RESET] Installing Ruby..";
rvm install ruby;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Python2..";
sudo apt-get install -y python-minimal;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Node & NPM..";
sudo apt-get install -y npm;
sudo apt-get install -y nodejs-legacy;
echo -e "[$GREEN+$RESET] Done.";

#sudo apt-get install -y python-minimal;
#sudo apt-get install -y npm;
#sudo apt-get install -y nodejs-legacy;

echo -e "[$GREEN+$RESET] Installing rename..";
sudo apt-get install -y rename;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing snap..";
sudo apt-get install -y snap;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Docker..";
sudo apt-get install -y docker.io;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Subfinder..";
go get github.com/subfinder/subfinder;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing amass..";
sudo snap install amass;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing massdns..";
git clone https://github.com/blechschmidt/massdns.git;
cd massdns;
docker build -t massdns .;
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

## SUBDOMAINDB AND NGINX CAN BE REPLACED BY CUSTOM LARAVEL+DOCKER FOR DEPENDENCIES

echo -e "[$GREEN+$RESET] Installing Aquatone..";
gem install aquatone;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing Nginx.."; #needs new dashboard
sudo apt-get install -y nginx;
echo -e "[$GREEN+$RESET] Removing default Nginx setup..";
sudo rm /etc/nginx/sites-available/default;
sudo rm /etc/nginx/sites-enabled/default;
echo -e "[$GREEN+$RESET] Configuring ReconPi Nginx setup..";
sudo cp $HOME/ReconPi/dashboard-nginx /etc/nginx/sites-available/;
sudo ln -s /etc/nginx/sites-available/dashboard-nginx /etc/nginx/sites-enabled/dashboard-nginx;
sudo service nginx restart;
sudo nginx -t;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";
