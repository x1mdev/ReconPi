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
BASE="$HOME/ReconPi"
domain="$1"
#BASERESULT="$HOME/assets" # check
RESULTDIR="$HOME/assets/$domain"
SCREENSHOTS="$RESULTDIR/screenshots"
WORDLIST="$BASE/wordlists"
CORS="$RESULTDIR/cors"
SUBS="$RESULTDIR/subdomains"
HTML="$RESULTDIR/html"
# check
# IPS="$RESULTDIR/ip"
# PORTSCAN="$RESULTDIR/portscan"
# DIRSCAN="$RESULTDIR/directories"

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
        # mkdir -p "$IPS"
        # mkdir -p "$PORTSCAN"
        # mkdir -p "$DIRSCAN"
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
    startFunction "subfinder"
    "$HOME"/go/bin/subfinder -d "$domain" -t 50 -b -w "$WORDLIST"/all.txt "$domain" -nW --silent -o "$SUBS/subfinder-online.txt" #-rL "$BASE"/wordlists/resolvers.txt
    echo -e "[$GREEN+$RESET] Done."

    startFunction "assetfinder"
    "$HOME"/go/bin/assetfinder --subs-only "$domain" >"$SUBS/assetfinder-online.txt"
    echo -e "[$GREEN+$RESET] Done."

    
    echo -e "[$GREEN+$RESET] COMBINE & SORT SUBFINDER"
    cat "$SUBS"/*.txt | sort | awk '{print tolower($0)}' | uniq > "$SUBS"/subdomains.txt
    echo -e "[$GREEN+$RESET] Done."
}

: 'subdomain takeover check'
checkTakeovers() {
    startFunction "subjack"
    "$HOME"/go/bin/subjack -a -ssl -t 50 -v -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json -w "$SUBS"/subdomains.txt -o "$SUBS"/takeovers.tmp
    cat "$SUBS"/takeovers.tmp | grep -v "Not Vulnerable" > "$SUBS"/takeovers.txt
    rm "$SUBS"/takeovers.tmp
    echo -e "[$GREEN+$RESET] Done."
}

: 'Use aquatone+chromium-browser to gather screenshots'
gatherScreenshots() {
    cat "$SUBS"/subdomains.txt | "$HOME"/go/bin/aquatone -http-timeout 10000 -scan-timeout 300 -ports xlarge -out "$SCREENSHOTS"/aquatone/
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
    python3 linkfinder.py -i "$SUBS"/subdomains.txt -d -o "$HTML"linkfinder-results.html
    # grep from meg results?
    # needs some efficiency
}

: 'directory brute-force'
startBruteForce() {
    gobuster dir -u "$SCREENSHOTS"/aquatone/aquatone_urls.txt -w "$WORDLIST"/wordlist.txt -q -n -e | tee bruteforce-endpoints.txt
    # on live target gathered by aquatone
    # -u prob needs fix
}

: 'results overview'
resultsOverview()
{
  echo -e "Finished"
  echo -e "[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]"
#   echo -e $(cat "$RESULTDIR"/bruteforce-online.txt | wc -l) "- bruteforce"
#   echo -e $(cat "$RESULTDIR"/amass.txt | wc -l) "- amass"
#   echo -e $(cat "$RESULTDIR"/subfinder-online.txt | wc -l) "- subfinder"
#   echo -e $(cat "$RESULTDIR"/assetfinder-online.txt | wc -l) "- assetfinder"
#   echo -e $(cat "$RESULTDIR"/altdns-wordlist.txt | wc -l) "- altdns"
#   echo -e $(cat "$RESULTDIR"/sublert-output.txt | wc -l) "- sublert"
#   echo -e $(cat "$RESULTDIR"/subdomains.txt | wc -l) "- total"
#   echo -e $(cat "$RESULTDIR"/subs-filtered.txt | wc -l) "- filtered/online"

#   Change function -> collect all useful files and show them on pi ip address (127.0.0.1/$domain.html <- aquatone results etc)
  echo -e "[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]"
}



: 'Execute the main functions'
displayLogo
checkArguments
checkDirectories
gatherSubdomains
checkTakeovers
gatherScreenshots
### todo
#   startMeg
#   Startlinkfinder
#   startBruteForce