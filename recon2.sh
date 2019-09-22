#!/bin/bash
: '
	@name   ReconPi recon.sh
	@author Martijn B <Twitter: @x1m_martijn>
	@link   https://github.com/x1mdev/ReconPi
'

: 'Set the main variables'
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RESET="\033[0m"
domain="$1"
BASE="$HOME/ReconPi"
WORDLIST="$BASE/wordlists"
RESULTDIR="$HOME/assets/$domain"
SCREENSHOTS="$RESULTDIR/screenshots"
CORS="$RESULTDIR/cors"
SUBS="$RESULTDIR/subdomains"
DIRSCAN="$RESULTDIR/directories"
HTML="$RESULTDIR/html"
# check
# IPS="$RESULTDIR/ip"
# PORTSCAN="$RESULTDIR/portscan"
#

VERSION="2.0"

: 'Display the logo'
displayLogo() {
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

: 'Display help text when no arguments are given'
checkArguments() {
    if [[ -z $domain ]]; then
        echo -e "[$GREEN+$RESET] Usage: recon <domain.tld>"
        exit 1
    fi
}

checkDirectories() {
    if [ ! -d "$RESULTDIR" ]; then
        echo -e "[$GREEN+$RESET] Creating new directories for $GREEN$domain$RESET"
        mkdir -p "$RESULTDIR"
        mkdir -p "$SUBS"
        mkdir -p "$CORS"
        mkdir -p "$SCREENSHOTS"
        mkdir -p "$DIRSCAN"
        # mkdir -p "$IPS"
        # mkdir -p "$PORTSCAN"
        #cd $ROOT/$domain
    fi
}
startFunction() {
    tool=$1
    echo -e "[$GREEN+$RESET] Starting $tool"
}

#: 'Gather resolvers'
# gatherResolvers()
# {

#}

: 'subdomain gathering'
gatherSubdomains() {
    startFunction "sublert"
    echo -e "checking sublert output, otherwise add it."
    if [ ! -e "$SUBS"/sublert-recon.txt ]; then
        cd "$HOME"/sublert || return
        python3 sublert.py -u "$domain"
        cp "$HOME"/tools/sublert/output/"$domain".txt "$SUBS"/sublert.txt
        cd "$HOME" || return
    else
        cp "$HOME"/sublert/output/"$domain".txt "$SUBS"/sublert.txt
    fi
    echo -e "Done, next."

    startFunction "subfinder"
    "$HOME"/go/bin/subfinder -d "$domain" -t 50 -b -w "$WORDLIST"/all.txt "$domain" -nW --silent -o "$SUBS/subfinder.txt" #-rL "$BASE"/wordlists/resolvers.txt
    echo -e "[$GREEN+$RESET] Done, next."

    startFunction "assetfinder"
    "$HOME"/go/bin/assetfinder --subs-only "$domain" >"$SUBS/assetfinder.txt"
    echo -e "[$GREEN+$RESET] Done, next."

    startFunction "amass"
    "$HOME"/go/bin/amass enum -d "$domain" -o "$SUBS"/amass.txt
    echo -e "[$GREEN+$RESET] Done, next."

    echo -e "[$GREEN+$RESET] Combining and sorting results.."
    cat "$SUBS"/*.txt | sort -u >"$SUBS"/subdomains.txt
    echo -e "[$GREEN+$RESET] Done."
}

: 'subdomain takeover check'
checkTakeovers() {
    startFunction "subjack"
    "$HOME"/go/bin/subjack -w "$SUBS"/subdomains.txt -a -ssl -t 50 -v -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json -o "$SUBS"/all-takeover-checks.txt -ssl
    grep -v "Not Vulnerable" <"$SUBS"/all-takeover-checks.txt >"$SUBS"/takeovers.txt
    rm "$SUBS"/all-takeover-checks.txt
    echo -e "[$GREEN+$RESET] Done."
}

: 'Use aquatone+chromium-browser to gather screenshots'
gatherScreenshots() {
    "$HOME"/go/bin/aquatone -http-timeout 10000 -scan-timeout 300 -ports xlarge -out "$SCREENSHOTS" <"$SUBS"/subdomains.txt
}

: 'Use the CORScanner to check for CORS misconfigurations'
checkCORS() {
    python3 "$HOME"/tools/CORScanner/cors_scan.py -v -t 50 -i "$SUBS"/subdomains.txt | tee "$CORS"/cors.txt
    echo -e "[$GREEN+$RESET] Done."
}

: 'Gather information with meg'
startMeg() {
    # todo
    meg -d 1000 -v /
}

: 'Gather endpoints with LinkFinder'
Startlinkfinder() {
    # todo
    grep -rnw "$RESULTDIR/out/" -e '.js'
    python3 linkfinder.py -i "$SUBS"/subdomains.txt -d -o "$HTML"/linkfinder.html
    # grep from meg results?
    # needs some efficiency
}

: 'directory brute-force'
startBruteForce() {
    for url in $(cat "$SCREENSHOTS"/aquatone/aquatone_urls.txt); do
        targets=$(echo $url | sed -e 's;https\?://;;' | sed -e 's;/.*$;;')
        echo "$targets" >>"$SUBS"/"$domain"-live.txt
        sort -u "$SUBS"/"$domain"-live.txt -o "$SUBS"/"$domain"-live.txt
    done

    for line in $(cat "$SUBS"/"$domain"-live.txt); do
        "$HOME"/go/bin/gobuster dir -u https://"$line" -w "$WORDLIST"/wordlist.txt -e -q -k -n -o "$DIRSCAN"/"$line".txt
    done
}

: 'Clean up'
cleanUp() {
    echo -e "[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]"
    #   echo -e Results:
    #   echo -e $(cat "$SUBS"/subdomains.txt | wc -l) "- Gathered subdomains."
    #   echo -e $(cat "$SUBS"/takeovers.txt | wc -l) "- Possible subdomain takeovers."
    #   echo -e $(cat "$CORS"/cors.txt | wc -l) "- CORS misconfigurations."

    #   Change function -> collect all useful files and show them on pi ip address (127.0.0.1/$domain.html <- aquatone results etc)
    #   rm some no longer needed files
    echo -e "Finished"
    echo -e "[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]"
}

: 'Execute the main functions'
displayLogo
checkArguments
checkDirectories
gatherSubdomains
checkTakeovers
gatherScreenshots
startBruteForce
### todo
#   startCors
#   startMeg
#   Startlinkfinder
#   cleanUp
