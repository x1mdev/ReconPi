#!/bin/bash
: '
@name   ReconPi install.sh
@author Martijn B <Twitter: @x1m_martijn>
@link   https://github.com/x1mdev/ReconPi
'

: 'Set the main variables'
YELLOW="\033[133m"
GREEN="\033[032m"
RESET="\033[0m"
VERSION="2.2"

: 'Display the logo'
displayLogo() {
	clear
	echo -e "
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                            
			v$VERSION - $YELLOW@x1m_martijn$RESET"
		}

	: 'Basic requirements'
	basicRequirements() {
		echo -e "[$GREEN+$RESET] This script will install the required dependencies to run recon.sh, please stand by.."
		echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)"
		cd "$HOME" || return
		sleep 1
		echo -e "[$GREEN+$RESET] Getting the basics.."
		export LANGUAGE=en_US.UTF-8
		export LANG=en_US.UTF-8
		export LC_ALL=en_US.UTF-8
		sudo apt-get update -y
		sudo apt-get install git -y
		git clone https://github.com/x1mdev/ReconPi.git
		sudo apt-get install -y --reinstall build-essential
		sudo apt install -y python3-pip
		sudo apt install -y file
		sudo apt-get install -y dnsutils
		sudo apt install -y lua5.1 alsa-utils libpq5
		sudo apt-get autoremove -y
		sudo apt clean
		#echo -e "[$GREEN+$RESET] Stopping Docker service.."
		#sudo systemctl disable docker.service
		#sudo systemctl disable docker.socket
		echo -e "[$GREEN+$RESET] Creating directories.."
		mkdir -p "$HOME"/tools
		mkdir -p "$HOME"/go
		mkdir -p "$HOME"/go/src
		mkdir -p "$HOME"/go/bin
		mkdir -p "$HOME"/go/pkg
		sudo chmod u+w .
		echo -e "[$GREEN+$RESET] Done."
	}

: 'Golang initials'
golangInstall() {
	echo -e "[$GREEN+$RESET] Installing and setting up Go.."

	if [[ $(go version | grep -o '1.14') == 1.14 ]]; then
		echo -e "[$GREEN+$RESET] Go is already installed, skipping installation"
	else
		cd "$HOME"/tools || return
		git clone https://github.com/udhos/update-golang
		cd "$HOME"/tools/update-golang || return
		sudo bash update-golang.sh
		sudo cp /usr/local/go/bin/go /usr/bin/ 
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Adding recon alias & Golang to "$HOME"/.bashrc.."
	sleep 1
	configfile="$HOME"/.bashrc

	if [ "$(cat "$configfile" | grep '^export GOPATH=')" == "" ]; then
		echo export GOPATH='$HOME'/go >>"$HOME"/.bashrc
	fi

	if [ "$(echo $PATH | grep $GOPATH)" == "" ]; then
		echo export PATH='$PATH:$GOPATH'/bin >>"$HOME"/.bashrc
	fi

	if [ "$(cat "$configfile" | grep '^alias recon=')" == "" ]; then
		echo "alias recon=$HOME/ReconPi/recon.sh" >>"$HOME"/.bashrc
	fi

	bash /etc/profile.d/golang_path.sh

	source "$HOME"/.bashrc

	cd "$HOME" || return
	echo -e "[$GREEN+$RESET] Golang has been configured."
}

: 'Golang tools'
golangTools() {
	echo -e "[$GREEN+$RESET] Installing subfinder.."
	GO111MODULE=on go get -u -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing subjack.."
	go get -u -v github.com/haccer/subjack
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing aquatone.."
	go get -u -v github.com/michenriksen/aquatone
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing httprobe.."
	go get -u -v github.com/tomnomnom/httprobe
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing assetfinder.."
	go get -u -v github.com/tomnomnom/assetfinder
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing meg.."
	go get -u -v github.com/tomnomnom/meg
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing tojson.."
	go get -u -v github.com/tomnomnom/hacks/tojson
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing unfurl.."
	go get -u -v github.com/tomnomnom/unfurl
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing gf.."
	go get -u -v github.com/tomnomnom/gf
	echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
	cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf
	cd "$HOME"/tools/ || return
	git clone https://github.com/1ndianl33t/Gf-Patterns
	cp ~/Gf-Patterns/*.json ~/.gf
	git clone https://github.com/dwisiswant0/gf-secrets
	cp "$HOME"/tools/gf-secrets/.gf/*.json ~/.gf
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing anew.."
	go get -u -v github.com/tomnomnom/anew
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing qsreplace.."
	go get -u -v github.com/tomnomnom/qsreplace
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing ffuf (Fast web fuzzer).."
	go get -u -v github.com/ffuf/ffuf
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing gobuster.."
	go get -u -v github.com/OJ/gobuster
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing Amass.."
	GO111MODULE=on go get -v github.com/OWASP/Amass/v3/...
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing getJS.."
	go get -u -v github.com/003random/getJS
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing getallURL.."
	go get -u -v github.com/lc/gau
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing shuffledns.."
	GO111MODULE=on go get -u -v github.com/projectdiscovery/shuffledns/cmd/shuffledns
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing dnsprobe.."
	GO111MODULE=on go get -u -v github.com/projectdiscovery/dnsprobe
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing nuclei.."
	GO111MODULE=on go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing cf-check"
	go get -u github.com/dwisiswant0/cf-check
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing dalfox"
	GO111MODULE=on go get -u -v github.com/hahwul/dalfox
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing hakrawler"
	go get -u -v github.com/hakluke/hakrawler
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing naabu"
	GO111MODULE=on go get -u -v github.com/projectdiscovery/naabu/cmd/naabu
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing chaos"
	GO111MODULE=on go get -u github.com/projectdiscovery/chaos-client/cmd/chaos
	echo -e "[$GREEN+$RESET] Done."

        echo -e "[$GREEN+$RESET] Installing httpx"
	GO111MODULE=on go get -u -v github.com/projectdiscovery/httpx/cmd/httpx
	echo -e "[$GREEN+$RESET] Done."
	
	echo -e "[$GREEN+$RESET] Installing crobat"
	go get -u github.com/cgboal/sonarsearch/crobat
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing slackcat"
	go get -u github.com/dwisiswant0/slackcat
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing github-subdomains"
	go get -u github.com/gwen001/github-subdomains
	echo -e "[$GREEN+$RESET] Done."
}

: 'Additional tools'
additionalTools() {
	echo -e "[$GREEN+$RESET] Installing massdns.."
	if [ -e /usr/local/bin/massdns ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/blechschmidt/massdns.git
		cd "$HOME"/tools/massdns || return
		echo -e "[$GREEN+$RESET] Running make command for massdns.."
		make -j
		sudo cp "$HOME"/tools/massdns/bin/massdns /usr/local/bin/
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing nuclei-templates.."
	nuclei -update-templates
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing jq.."
	sudo apt install -y jq
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing Chromium browser.."
	sudo apt install -y chromium-browser
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing masscan.."
	if [ -e /usr/local/bin/masscan ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/robertdavidgraham/masscan
		cd "$HOME"/tools/masscan || return
		make -j
		sudo cp bin/masscan /usr/local/bin/masscan
		sudo apt install libpcap-dev -y
		cd "$HOME"/tools/ || return
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing Corsy (CORS Misconfiguration Scanner).."
	if [ -e "$HOME"/tools/Corsy/corsy.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/s0md3v/Corsy.git
		cd "$HOME"/tools/Corsy || return
		sudo pip3 install -r requirements.txt
		cd "$HOME"/tools/ || return
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing dirsearch.."
	if [ -e "$HOME"/tools/dirsearch/dirsearch.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/maurosoria/dirsearch.git
		cd "$HOME"/tools/ || return
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing Arjun (HTTP parameter discovery suite).."
	if [ -e "$HOME"/tools/Arjun/arjun.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/s0md3v/Arjun.git
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing Dnsgen .."
	if [ -e "$HOME"/tools/dnsgen/setup.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/ProjectAnte/dnsgen
		cd "$HOME"/tools/dnsgen || return
		pip3 install -r requirements.txt --user
		sudo python3 setup.py install
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing sublert.."
	if [ -e "$HOME"/tools/sublert/sublert.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/yassineaboukir/sublert.git
		cd "$HOME"/tools/sublert || return
		sudo apt-get install -y libpq-dev dnspython psycopg2 tld termcolor
		pip3 install -r requirements.txt --user
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing findomain.."
	arch=`uname -m`
	if [ -e "$HOME"/tools/findomain ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	elif [[ "$arch" == "x86_64" ]]; then
		wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O "$HOME"/tools/findomain
		chmod +x "$HOME"/tools/findomain
		sudo cp "$HOME"/tools/findomain /usr/local/bin
		echo -e "[$GREEN+$RESET] Done."
	else
		wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-aarch64 -O "$HOME"/tools/findomain
		chmod +x "$HOME"/tools/findomain
		sudo cp "$HOME"/tools/findomain /usr/local/bin
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing LinkFinder.."
	# needs check
	if [ -e "$HOME"/tools/LinkFinder/linkfinder.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/GerbenJavado/LinkFinder.git
		cd "$HOME"/tools/LinkFinder || return
		pip3 install -r requirements.txt --user
		sudo python3 setup.py install
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing bass.."
	# needs check
	if [ -e "$HOME"/tools/bass/bass.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/Abss0x7tbh/bass.git
		cd "$HOME"/tools/bass || return
		sudo pip3 install tldextract
		pip3 install -r requirements.txt --user
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing interlace.."
	if [ -e /usr/local/bin/interlace ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/codingo/Interlace.git
		cd "$HOME"/tools/Interlace || return
		sudo python3 setup.py install
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing nmap.."
		sudo apt-get install -y nmap
		wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse -O /usr/share/nmap/scripts/vulners.nse && nmap --script-updatedb
		echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing SecLists.."
	if [ -e "$HOME"/tools/Seclists/Discovery ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/danielmiessler/SecLists.git
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing Altdns.."
	pip install py-altdns
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing Eyewitness.."
	cd "$HOME"/tools/ || return
	git clone https://github.com/FortyNorthSecurity/EyeWitness.git
	sudo bash "$HOME"/tools/EyeWitness/Python/setup/setup.sh
	echo -e "[$GREEN+$RESET] Done."
}

: 'Dashboard setup'
setupDashboard() {
	echo -e "[$GREEN+$RESET] Installing Nginx.."
	sudo apt-get install -y nginx
	sudo nginx -t
	echo -e "[$GREEN+$RESET] Done."
}

: 'Finalize'
finalizeSetup() {
	echo -e "[$GREEN+$RESET] Finishing up.."
	displayLogo
	source "$HOME"/.bashrc || return
	echo -e "[$GREEN+$RESET] Installation script finished! "
}

: 'Execute the main functions'
displayLogo
basicRequirements
golangInstall
golangTools
additionalTools
setupDashboard
finalizeSetup
