#!/bin/bash
# ReconPi install.sh by @x1m_martijn
# https://github.com/x1mdev/ReconPi

echo '
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                        v0.1.0 - by @x1m_martijn
                        
        '

echo "[+] This script will install the required tools to run recon.sh, please stand by..";
echo "[+] It will take a while, go grab a cup of coffee :)";
sleep 1;
echo "[+] Getting the basics..";
sudo apt-get update -y;
sudo apt-get upgrade -y;

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

#echo "[+] Installing bash_profile aliases from recon_profile..";
#git clone https://github.com/nahamsec/recon_profile.git;
#cd recon_profile;
#cat bash_profile >> ~/.bash_profile;
#source ~/.bash_profile;
#cd ~/tools/;
#echo "[+] Done.";

#docker -v;
#sudo systemctl status docker --no-pager;
#echo "[+] Docker installation complete.";

sleep 1;
ls -la;
echo "[+] Script finished!";