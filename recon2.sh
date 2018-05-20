#!/bin/bash

URL=$1;
root="$HOME/bugbounty";

function empty {
    if [[ $(echo $1 | wc -m) == 1 ]]; then
            echo "Usage: ./recon.sh [domain.tld]";
            exit;
    fi
}

# "Borrowed" these 2 functions from yung hax (https://github.com/lilgio)

function dirCheck {
        if [ -d $1 ]; then
                mkdir -p $root;
        fi
}

empty "$URL";
dirCheck "$root";

echo "[+] Building new directory";

cd $root;
mkdir $URL;
echo "[+] Navigating to $URL;
cd $URL;
echo "[+] Checking if the Subfinder Docker image is loaded..";

echo "[+] Docker image is loaded! Running Subfinder on"
docker run -v $HOME/.config/subfinder:/root/.config/subfinder -it subfinder -d x1m.nl > x1m.nl.txt