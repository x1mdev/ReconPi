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

echo -e "[$GREEN+$RESET] Creating directories..";
cd $HOME;
mkdir -p tools;
mkdir -p go;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing and setting up Go..";
sudo apt-get install -y golang-go;
# set export crap right
echo -e 'export GOPATH=$HOME/go/bin' >> ~/.profile;
echo -e 'export GOROOT=$HOME/go' >> ~/.profile;
echo -e 'export GOBIN=$GOPATH/bin' >> ~/.profile;
echo -e 'export PATH=$PATH:$GOPATH' >> ~/.profile;
echo -e 'export PATH=$PATH:$GOROOT/bin' >> ~/.profile;
source ~/.profile;
go version;
go env;
# extra dependencies, beautify later
sudo apt-get install -y ruby;
sudo apt-get install -y python-minimal;
sudo apt-get install -y npm;
sudo apt-get install -y nodejs-legacy;

echo -e "[$GREEN+$RESET] Installing rename..";
sudo apt-get install -y rename;
echo -e "[$GREEN+$RESET] rename installation complete.";

echo -e "[$GREEN+$RESET] Installing snap..";
sudo apt-get install -y snap;
echo -e "[$GREEN+$RESET] snap installation complete.";

echo -e "[$GREEN+$RESET] Installing Docker..";
sudo apt-get install -y docker.io;
echo -e "[$GREEN+$RESET] Docker installation complete.";

echo -e "[$GREEN+$RESET] Installing Subfinder..";
go get github.com/subfinder/subfinder
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

cd $HOME/tools/;
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

echo -e "[$GREEN+$RESET] Installing Nginx..";
sudo apt-get install -y nginx;
echo -e "[$GREEN+$RESET] Removing default Nginx setup..";
sudo rm /etc/nginx/sites-available/default;
sudo rm /etc/nginx/sites-enabled/default;
echo -e "[$GREEN+$RESET] Configuring ReconPi Nginx setup..";
sudo cp $HOME/ReconPi/dashboard /etc/nginx/sites-available/;
sudo ln -s /etc/nginx/sites-available/dashboard /etc/nginx/sites-enabled/dashboard;
sudo service nginx restart;
sudo nginx -t;
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Installing subdomainDB..";
cd $HOME/;
git clone https://github.com/smiegles/subdomainDB.git;
cd subdomainDB;
docker build --rm -t subdomaindb .;
echo -e "[$GREEN+$RESET] Starting up the dashboard..";
docker run -d -v subdomainDB:/subdomainDB -p 127.0.0.1:4000:4000 subdomaindb;
sudo nginx -s reload;
echo -e "[$GREEN+$RESET] Dashboard is up and running!";
cd $HOME/tools/;
echo -e "[$GREEN+$RESET] Done.";

echo -e "[$GREEN+$RESET] Final step..";

if [ -d tools ];then
	# keypressed, read 1 char from stdin using dd
	# works using any sh-shell
	readkbd(){
		stty -icanon -echo
		dd bs=1 count=1 2>/dev/null
		stty icanon echo
}

while printf "[$GREEN+$RESET] Install aquatone-docker? This will take some extra time [Default NO]:N\b" # default N to continue script
	  response=$(readkbd)
	  printf "\r				\n"
	  case "$response" in
	  			Y|y) response="Y" ;; 
				n|N|"") response="N" ;; # default = ENTER
				*) response="N"	;;
	  esac
	  [ "$response" = "Y" ]
do
                                echo -e "[$GREEN+$RESET] Installing aquatone-docker..";
                                git clone https://github.com/x1mdev/aquatone-docker.git;
                                cd aquatone-docker;
                                docker build -t aquatone .;
                                cd $HOME/tools/;
                                done;
                                echo -e "[$GREEN+$RESET] Done.";
fi

sleep 1;
ls -la;
displayLogo;
echo -e "[$GREEN+$RESET] Script finished!";