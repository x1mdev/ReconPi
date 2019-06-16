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
VERSION="2.0"


: 'Display the logo'
displayLogo()
{
    clear;
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

: 'Basic requirements'
basicRequirements()
{
    echo -e "[$GREEN+$RESET] This script will install the required dependencies to run recon.sh, please stand by..";
    echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)";
    cd "$HOME"  || return;
    sleep 1;
    echo -e "[$GREEN+$RESET] Getting the basics..";
    export LANGUAGE=en_US.UTF-8;
    export LANG=en_US.UTF-8;
    export LC_ALL=en_US.UTF-8;
    locale-gen en_US.UTF-8;
    sudo apt-get update -y;
    # sudo apt-get install -y \
    #    apt-transport-https \
    #    ca-certificates \
    #    curl \
    #    gnupg2 \
    #    software-properties-common
    # curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
    # sudo apt-get upgrade -y;
    sudo apt-get install -y --reinstall build-essential;
    sudo apt install -y python3-pip;
    sudo apt-get install -y dnsutils;
    sudo apt install -y lua5.1 alsa-utils; # still needed
    echo -e "[$GREEN+$RESET] Done."
}

: 'Golang initials'
golangInstall()
{
    echo -e "[$GREEN+$RESET] Installing and setting up Go..";
    cd "$HOME" || return;
    wget https://dl.google.com/go/go1.11.1.linux-armv6l.tar.gz;
    sudo tar -C /usr/local -xvf go1.11.1.linux-armv6l.tar.gz;
    echo -e "[$GREEN+$RESET] Creating directories..";
    mkdir -p "$HOME"/tools;
    mkdir -p "$HOME"/go;
    mkdir -p "$HOME"/go/src;
    mkdir -p "$HOME"/go/bin;
    mkdir -p "$HOME"/go/pkg;
    sleep 1;
    sudo chmod u+w .;
    #sudo apt install -y golang;
    echo -e "[$GREEN+$RESET] Done.";
    echo -e "[$GREEN+$RESET] Adding recon alias & Golang to ~/.bashrc..";
    sleep 1;
    sudo rm -rf /usr/bin/go;
    sudo ln -s /usr/local/go/bin/go /usr/bin/go
    echo -e "export GOPATH=$HOME/go" >> "$HOME"/.bashrc;
    echo -e 'export GOROOT=/usr/local/go' >> "$HOME"/.bashrc;
    echo -e "export PATH=$PATH:$HOME/go/bin/" >> "$HOME"/.bashrc;
    echo -e "export PATH=$PATH:$GOROOT/bin" >> "$HOME"/.bashrc;
    echo -e "export PATH=$PATH:$HOME/.local/bin" >> "$HOME"/.bashrc;
    echo -e "alias recon='bash $HOME/ReconPi/recon.sh'" >> "$HOME"/.bashrc;
    #alias recon='bash $HOME/ReconPi/recon.sh'
    sleep 1;
    source "$HOME"/.bashrc;
    cd "$HOME" || return;
    echo -e "[$GREEN+$RESET] Golang has been configured, checking go env..";
    go version;
    go env;
    sleep 1;
}

: 'Golang tools'
golangTools()
{
    echo -e "[$GREEN+$RESET] Installing Subfinder..";
    go get github.com/subfinder/subfinder;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing SubOver"
    go get github.com/Ice3man543/SubOver;
    echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing online..";
    go get -u github.com/003random/online;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing gobuster..";
    cd "$HOME"/go/src  || return;
    mkdir -p OJ;
    cd "$HOME"/go/src/OJ  || return;
    git clone https://github.com/OJ/gobuster.git;
    cd "$HOME"/go/src/OJ/gobuster  || return;
    go get && go build;
    go install;
    echo -e "[$GREEN+$RESET] Done.";
    cd "$HOME"/tools/  || return;

    echo -e "[$GREEN+$RESET] Installing Amass.."
    go get -u github.com/OWASP/Amass/...;
    cd "$HOME"/go/src/github.com/OWASP/Amass || return;
    go install ./...;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing GetJS..";
    go get -u github.com/003random/getJS;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing tojson..";
    go get -u github.com/tomnomnom/hacks/tojson;
    echo -e "[$GREEN+$RESET] Done.";
    
}

: 'Additional tools'
additionalTools()
{
    echo -e "[$GREEN+$RESET] Installing massdns..";
    cd "$HOME"/tools/ || return;
    git clone https://github.com/blechschmidt/massdns.git && cd massdns;
    echo -e "[$GREEN+$RESET] Running make command for massdns..";
    make;
    sudo cp "$HOME"/tools/massdns/bin/massdns /usr/local/bin/;
    sudo apt-get install -y jq;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing altdns..";
    cd "$HOME"/tools/ || return;
    git clone https://github.com/infosec-au/altdns.git;
    pip install py-altdns --user;
    echo -e "[$GREEN+$RESET] Done.";


    echo -e "[$GREEN+$RESET] Installing masscan..";
    cd "$HOME"/tools/ || return;
    git clone https://github.com/robertdavidgraham/masscan && cd masscan;
    make -j;
    cd "$HOME"/tools/ || return;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing sublert..";
    # needs check
    git clone https://github.com/yassineaboukir/sublert.git && cd sublert;
    sudo apt-get install -y libpq-dev;
    pip3 install -r requirements.txt;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing virtual host discovery..";
    git clone https://github.com/jobertabma/virtual-host-discovery.git;
    cd "$HOME"/tools/ || return;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing nmap..";
    sudo apt-get install -y nmap;
    echo -e "[$GREEN+$RESET] Done.";
}

: 'Subdomain takeover setup'
subdomainTOcheck()
{
    echo -e "[$GREEN]+$RESET] Setting up subdomain takeover checks.."
    cd "$HOME" || return;
    mkdir "$HOME"/subdomain_takeover;
    cd "$HOME"/subdomain_takeover || return;
    git clone https://github.com/arkadiyt/bounty-targets-data;
}

: 'Dashboard setup'
setupDashboard()
{
    echo -e "[$GREEN+$RESET] Installing Nginx..";
    sudo apt-get install -y nginx;
    sudo nginx -t;
    cd "$HOME"/tools/  || return;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing Docker.."
    echo -e "so fast"
    # sudo apt install -y docker.io;
    # mv /usr/sbin/iptables /root/scripts/;
    # ln -s /usr/sbin/iptables-legacy /usr/sbin/iptables;
    # iptables;
    # systemctl start docker;
    # service docker start;
    # sudo systemctl enable docker;
    # sleep 1;
    echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing subdomainDB and starting it up..";
    cd "$HOME"/tools/  || return;
    git clone https://github.com/smiegles/subdomainDB.git;
    cd subdomainDB || return;
    docker build --rm -t subdomaindb .;
    cd "$HOME"/tools/ || return;
}

: 'Finalize'
finalizeSetup()
{
	echo -e "[$GREEN+$RESET] Finishing up..";
    displayLogo;
    cd "$HOME" || return;
    touch motd
    displayLogo >> motd;
    sudo mv "$HOME"/motd /etc/motd;
    cd "$HOME" || return;
    echo -e "[$GREEN+$RESET] Installation script finished! System will reboot to finalize installation.";
    sleep 1;
    sudo reboot;
}

: 'Execute the main functions'
displayLogo
basicRequirements
golangInstall
golangTools
additionalTools
subdomainTOcheck
setupDashboard
finalizeSetup