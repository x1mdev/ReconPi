#!/bin/bash
# ReconPi recon.sh by @x1m_martijn
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

URL=$1;
rootdir="$HOME/bugbounty";

function empty {
    if [[ $(echo $1 | wc -m) == 1 ]]; then
            echo "Usage: bash recon.sh [domain.tld]";
            exit;
    fi
}

function dirCheck {
        if [ -d $URL ]; then
                mkdir -p $rootdir;
        fi
}

empty "$URL";
dirCheck "$rootdir";

# "Borrowed" these 2 functions from yung hax (https://github.com/lilgio)

export URL=$(echo $1)

echo "[+] Building new directory";
mkdir -p $rootdir;
cd $rootdir;
mkdir -p $URL;
echo "[+] Navigating to $URL";
cd $URL;
echo "[+] Running Subfinder on $URL..";
docker run -v $HOME/.config/subfinder:/root/.config/subfinder -it subfinder -d $URL --silent > $URL.txt;
cat $URL.txt | grep $URL >> domains.txt;
rm $URL.txt;
echo "[+] Done, checking which domains resolve..";

if [ -e domains.txt ];then
	echo "[+] Subfinder scan complete, checking which domains resolve..";
	while read domain; 
	do if host "$domain" > /dev/null; 
	then echo $domain; 
	fi; 
	done < domains.txt >> resolveddomains.txt
	echo "[+] Resolved domains written to resolveddomains.txt";
	sleep 1;
        # not working yet, something is up
fi

echo "[+] Done, using cat resolveddomains.txt now:";
cat resolveddomains.txt;
echo "[+] Done, starting masscan."
docker run -it massdns -r lists/resolvers.txt -t A -o S -w resolveddomains.txt > massdns.txt;
# This doesn't work yet because I need to find a way to get the resolveddomains.txt from the host to docker.
echo "[+] Done!"