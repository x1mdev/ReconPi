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
BASERESULT="$HOME/assets" # check
RESULTDIR="$HOME/assets/$domain"
WORDLIST="$BASE/wordlists"
SUBS="$RESULTDIR/subdomains"
# check
CORS="$RESULTDIR/cors"
IPS="$RESULTS_PATH/ip"
PORTSCAN="$RESULTDIR/portscan"
SCREENSHOTS="$RESULTDIR/screenshots"
DIRSCAN="$RESULTDIR/directories"

TOOLS="$HOME/tools"

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

checkDirectory() {
    if [ ! -d "$RESULTDIR" ]; then
        echo -e "[$GREEN+$RESET] Creating new directory: $GREEN$RESULTDIR$RESET"
        mkdir -p "$RESULTDIR"
        #cd $ROOT/$domain
    fi
}
runMsg() {
    tool=$1
    echo -e "[$GREEN+$RESET] Running $tool"
}

~/go/bin/subfinder -d $TARGET -t 50 -b -w $WORDLIST_PATH/dns_all.txt $TARGET -nW --silent -o $SUB_PATH/subfinder.txt

#: 'Gather resolvers'
# gatherResolvers()
# {

#}

: 'subdomain gathering'
runSubdomains() {
    runMsg "subfinder"
    "$HOME"/go/bin/subfinder -d "$domain" -t 50 -b -w "$WORDLIST"/dns_all.txt "$domain" -nW --silent -o "$RESULTDIR/subfinder-online.txt" #-rL "$BASE"/wordlists/resolvers.txt
    echo -e "[$GREEN+$RESET] COMBINE & SORT SUBFINDER"
    cat "$RESULTDIR"/bruteforce-online.txt "$RESULTDIR"/subfinder-online.txt >>"$RESULTDIR"/subdomains.txt
    sort -u "$RESULTDIR/subdomains.txt" -o "$RESULTDIR/subdomains.txt"
    runMsg "assetfinder"
    "$HOME"/go/bin/assetfinder --subs-only "$domain" >"$RESULTDIR/assetfinder-online.txt"
    echo -e "[$GREEN+$RESET] COMBINE & SORT assetfinder RESULTS"
    cat "$RESULTDIR"/assetfinder-online.txt >>"$RESULTDIR"/subdomains.txt
    sort -u "$RESULTDIR/subdomains.txt" -o "$RESULTDIR/subdomains.txt"
}