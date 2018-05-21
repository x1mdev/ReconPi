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
VERSION="0.1.1"


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

displayLogo

echo "[+] This script will install the required tools to run recon.sh, please stand by..";
echo "[+] It will take a while, go grab a cup of coffee :)";
sleep 1;
echo "[+] Getting the basics..";
sudo apt-get update -y;
sudo apt-get upgrade -y;

echo "[+] Installing ReconPi..";
cd ~;
git clone https://github.com/x1mdev/ReconPi.git;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing Git..";
sudo apt-get install -y git;
echo "[+] Git installation complete.";

echo "[+] Installing rename..";
sudo apt-get install -y rename;
echo "[+] rename installation complete.";

echo "[+] Installing snap..";
sudo apt-get install -y snap;
echo "[+] snap installation complete.";

echo "[+] Installing pip..";
sudo apt-get install -y python3-pip;
apt-get install -y python-pip;
echo "[+] pip installation complete.";

echo "[+] Installing Docker..";
sudo apt-get install -y docker;
echo "[+] Docker installation complete.";


echo "[+] Creating the tools directory.."
mkdir -p tools;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing Subfinder..";
git clone https://github.com/x1mdev/subfinder.git;
cd subfinder;
docker build -t subfinder .;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing amass..";
sudo snap install amass;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing massdns..";
git clone https://github.com/blechschmidt/massdns.git;
cd massdns;
docker build -t massdns .;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing teh_s3_bucketeers..";
git clone https://github.com/tomdev/teh_s3_bucketeers.git;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing virtual host discovery..";
git clone https://github.com/jobertabma/virtual-host-discovery.git;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Installing nmap..";
sudo apt-get install -y nmap;
cd ~/tools/;
echo "[+] Done.";

echo "[+] Final step.."

if [ -d tools ];then
	# keypressed, read 1 char from stdin using dd
	# works using any sh-shell
	readkbd(){
		stty -icanon -echo
		dd bs=1 count=1 2>/dev/null
		stty icanon echo
}

while printf "[+] Install aquatone-docker? This will take some extra time:N\b" # default N to continue script
	  response=$(readkbd)
	  printf "\r				\n"
	  case "$response" in
	  			Y|y) response="Y" ;; 
				n|N|"") response="N" ;; # default = ENTER
				*) response="N"	;;
	  esac
	  [ "$response" = "Y" ]
do
                                echo "[+] Installing aquatone-docker..";
                                git clone https://github.com/x1mdev/aquatone-docker.git;
                                cd aquatone-docker;
                                docker build -t aquatone .;
                                cd ~/tools/;
                                done;
                                echo "[+] Done.";
fi

sleep 1;
ls -la;
displayLogo;
echo "[+] Script finished!";