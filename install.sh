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
    echo -e "[$GREEN+$RESET] This is the install script that will install the required dependencies to run recon.sh, please stand by..";
    echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)";
    cd $HOME  || return;
    sleep 1;
    echo -e "[$GREEN+$RESET] Getting the basics..";
    #sudo apt-get install git -y; # installed by default re4sonpi
    sudo apt-get update -y;
    #sudo apt-get upgrade -y; #uit voor test
    #sudo apt-get install -y gcc; # installed by default re4sonpi
    #sudo apt-get install -y build-essential; # installed by default re4sonpi
    sudo apt install -y lua5.1 alsa-utils; # still needed
    echo -e "[$GREEN+$RESET] Done."
}

: 'Golang initials'
golangInstall()
{
    echo -e "[$GREEN+$RESET] Installing and setting up Go..";
    cd "$HOME" || return;
    # wget https://dl.google.com/go/go1.12.4.linux-armv6l.tar.gz;
    # sudo tar -C /usr/local -xvf go1.12.4.linux-armv6l.tar.gz;
    apt-get install golang;
    echo -e "[$GREEN+$RESET] Creating directories..";
    sleep 1;
    mkdir -p $HOME/tools;
    mkdir -p $HOME/go;
    mkdir -p $HOME/go/src;
    mkdir -p $HOME/go/bin;
    mkdir -p $HOME/go/pkg;
    git clone https://github.com/x1mdev/ReconPi.git;
    sudo chmod u+w .;
    echo -e "[$GREEN+$RESET] Done.";
    echo -e "[$GREEN+$RESET] Adding recon alias & Golang to ~/.bashrc..";
    sleep 1;
    #echo -e 'export GOPATH=$HOME/go' >> $HOME/.bashrc;
    #echo -e 'export GOROOT=/usr/local/go' >> $HOME/.bashrc;
    echo -e 'export PATH=$PATH:$HOME/go/bin/' >> $HOME/.bashrc;
    #echo -e 'export PATH=$PATH:$GOROOT/bin' >> $HOME/.bashrc;
    #echo -e 'export PATH=$PATH:$HOME/.local/bin' >> $HOME/.bashrc;
    echo -e "alias recon='bash $HOME/ReconPi/recon.sh'" >> $HOME/.bashrc;
    alias recon='bash $HOME/ReconPi/recon.sh'
    sleep 1;
    source $HOME/.bashrc;
    cd $HOME  || return;
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

    echo -e "[$GREEN+$RESET] Installing online..";
    go get -u github.com/003random/online;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing gobuster..";
    cd $HOME/go/src  || return;
    mkdir -p OJ;
    cd $HOME/go/src/OJ  || return;
    git clone https://github.com/OJ/gobuster.git;
    cd $HOME/go/src/OJ/gobuster  || return;
    go get && go build;
    go install;
    echo -e "[$GREEN+$RESET] Done.";
    cd $HOME/tools/  || return;

    echo -e "[$GREEN+$RESET] Installing Amass.."
    go get -u github.com/OWASP/Amass/...;
    cd $HOME/go/src/github.com/OWASP/Amass;
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
    cd $HOME/tools/ || return;
    git clone https://github.com/blechschmidt/massdns.git;
    cd massdns;
    echo -e "[$GREEN+$RESET] Running make command for massdns..";
    make;
    sudo cp $HOME/tools/massdns/bin/massdns /usr/local/bin/;
    sudo apt-get install -y jq;
    cd $HOME/tools/ || return;
    echo -e "[$GREEN+$RESET] Done.";

    # echo -e "[$GREEN+$RESET] Installing teh_s3_bucketeers..";
    # git clone https://github.com/tomdev/teh_s3_bucketeers.git;
    # cd $HOME/tools/ || return;
    # echo -e "[$GREEN+$RESET] Done.";

    # echo -e "[$GREEN+$RESET] Installing virtual host discovery..";
    # git clone https://github.com/jobertabma/virtual-host-discovery.git;
    # cd $HOME/tools/ || return;
    # echo -e "[$GREEN+$RESET] Done.";

    # echo -e "[$GREEN+$RESET] Installing nmap..";
    # sudo apt-get install -y nmap;
    # cd $HOME/tools/ || return;
    # echo -e "[$GREEN+$RESET] Done.";
}

: 'Dashboard setup'
setupDashboard()
{
    echo -e "[$GREEN+$RESET] Installing Nginx..";
    sudo apt-get install -y nginx;
    sudo nginx -t;
    cd $HOME/tools/  || return;
    echo -e "[$GREEN+$RESET] Done.";

    echo -e "[$GREEN+$RESET] Installing Docker.."
    sudo apt install -y docker.io;
    service docker start;
    sudo systemctl enable docker;
    sleep 1;
    echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing subdomainDB and starting it up..";
    cd $HOME/tools/  || return;
    git clone https://github.com/smiegles/subdomainDB.git;
    cd subdomainDB;
    docker build --rm -t subdomaindb .;
    cd $HOME/tools/ || return;
}

: 'Finalize'
finalizeSetup()
{
	echo -e "[$GREEN+$RESET] Finishing up..";
    displayLogo;
    cd "$HOME" || return;
    touch motd
    displayLogo >> motd;
    sudo mv $HOME/motd /etc/motd;
    cd $HOME || return;
    #rm go1.11.1.linux-armv6l.tar.gz;
    #rm install.sh; 
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
setupDashboard
finalizeSetup