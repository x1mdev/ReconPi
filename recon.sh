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
RESULTDIR="$HOME/assets/$domain"
WORDLIST="$RESULTDIR/wordlists"
SCREENSHOTS="$RESULTDIR/screenshots"
CORS="$RESULTDIR/cors"
SUBS="$RESULTDIR/subdomains"
DIRSCAN="$RESULTDIR/directories"
HTML="$RESULTDIR/html"
IPS="$RESULTDIR/ips"
VERSION="2.0"
# check
# IPS="$RESULTDIR/ip"
# PORTSCAN="$RESULTDIR/portscan"

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
    echo -e "[$GREEN+$RESET] Creating new directories and grabbing wordlists for $GREEN$domain$RESET.."
      mkdir -p "$RESULTDIR"
      mkdir -p "$SUBS"
      mkdir -p "$CORS"
      mkdir -p "$SCREENSHOTS"
      mkdir -p "$DIRSCAN"
      mkdir -p "$HTML"
      mkdir -p "$WORDLIST"
      mkdir -p "$IPS"
      sudo mkdir -p /var/www/html/"$domain"
    cp "$BASE"/wordlists/*.txt "$WORDLIST"
    # mkdir -p "$PORTSCAN"
    # cd $ROOT/$domain
  fi
}

startFunction() {
  tool=$1
  echo -e "[$GREEN+$RESET] Starting $tool"
}

: 'subdomain gathering'
gatherSubdomains() {
  startFunction "sublert"
  echo -e "[$GREEN+$RESET] Checking for existing sublert output, otherwise add it."
  if [ ! -e "$SUBS"/sublert.txt ]; then
    cd "$HOME"/tools/sublert || return
    python3 sublert.py -u "$domain"
    cp "$HOME"/tools/sublert/output/"$domain".txt "$SUBS"/sublert.txt
    cd "$HOME" || return
  else
    cp "$HOME"/sublert/output/"$domain".txt "$SUBS"/sublert.txt
  fi
  echo -e "[$GREEN+$RESET] Done, next."

  startFunction "subfinder"
  "$HOME"/go/bin/subfinder -d "$domain" -t 50 "$domain" -nW --silent -o "$SUBS/subfinder.txt" 
  echo -e "[$GREEN+$RESET] Done, next."

  startFunction "assetfinder"
  "$HOME"/go/bin/assetfinder --subs-only "$domain" >"$SUBS/assetfinder.txt"
  echo -e "[$GREEN+$RESET] Done, next."

  startFunction "amass"
  "$HOME"/go/bin/amass enum -d "$domain" -o "$SUBS"/amass.txt
  echo -e "[$GREEN+$RESET] Done, next."

  echo -e "[$GREEN+$RESET] Combining and sorting results.."
  cat "$SUBS"/*.txt | sort -u > "$SUBS"/subdomains.txt
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

: 'Gather resolvers with bass'
gatherResolvers()
{
  startFunction "bass (resolvers)"
  cd "$HOME"/tools/bass || return
  python3 bass.py -d "$domain" -o "$WORDLIST"/"$domain"-resolvers.txt
}

: 'Gather IPs with massdns'
gatherIPs(){
    startFunction "massdns"
    sudo /usr/local/bin/massdns -r "$WORDLIST"/"$domain"-resolvers.txt -q -t A -o S -w "$IPS"/massdns.raw "$SUBS"/subdomains.txt
    sudo cat "$IPS"/massdns.raw | grep -e ' A ' |  cut -d 'A' -f 2 | tr -d ' ' > "$IPS"/massdns.txt
    sort -u < "$IPS"/massdns.txt > "$IPS"/"$domain"-ips.txt
    echo -e "[$GREEN+$RESET] Done."
}

: 'Use aquatone+chromium-browser to gather screenshots'
gatherScreenshots() {
  startFunction "aquatone"
  "$HOME"/go/bin/aquatone -http-timeout 10000 -scan-timeout 300 -ports xlarge -out "$SCREENSHOTS" <"$SUBS"/subdomains.txt
}

: 'Use the CORScanner to check for CORS misconfigurations'
checkCORS() {
  startFunction "CORScanner"
  python3 "$HOME"/tools/CORScanner/cors_scan.py -v -t 50 -i "$SUBS"/subdomains.txt | tee "$CORS"/cors.txt
  echo -e "[$GREEN+$RESET] Done."
}

: 'Gather information with meg'
startMeg() {
  startFunction "meg"
  # todo
  meg -d 1000 -v /
}

: 'Gather endpoints with LinkFinder'
Startlinkfinder() {
  startFunction "LinkFinder"
  # todo
  grep -rnw "$RESULTDIR/out/" -e '.js'
  python3 linkfinder.py -i "$SUBS"/subdomains.txt -d -o "$HTML"/linkfinder.html
  # grep from meg results?
  # needs some efficiency
}

: 'directory brute-force'
startBruteForce() {
  startFunction "directory brute-force"
  for url in $(cat "$SCREENSHOTS"/aquatone_urls.txt); do
    targets=$(echo $url | sed -e 's;https\?://;;' | sed -e 's;/.*$;;')
    echo "$targets" >>"$SUBS"/"$domain"-live.txt
    sort -u "$SUBS"/"$domain"-live.txt -o "$SUBS"/"$domain"-live.txt
  done

  # maybe run with interlace?
  # needs finetuning
  for line in $(cat "$SUBS"/"$domain"-live.txt); do
    "$HOME"/go/bin/gobuster dir -u https://"$line" -w "$WORDLIST"/wordlist.txt -e -q -k -n -o "$DIRSCAN"/"$line".txt
  done
}

: 'Create HTML page for results'
makeHtml() {
  startFunction "HTML webpage"
  # some simple testing

  echo "<html><head></head><body>" >> "$HTML"/index.html
  echo "<table border=1>" >> "$HTML"/index.html
  echo "<h1>$domain</h1>" >> "$HTML"/index.html
  echo "<tr><td>Target</td><td>Subdomains</td><td>Ports</td><td>CORS</td><td>Screenshots</td><td>Takeovers</td></tr>" >> "$HTML"/index.html
  echo "<a href=http://$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')/screenshots/aquatone_report.html>Screenshots</a><br>" >> "$HTML"/index.html
  echo "<a href=$CORS/cors.txt>CORS misconfigurations</a><br>" >> "$HTML"/index.html
  echo "<a href=$DIRSCAN/$line.txt>dirscan results</a><br>" >> "$HTML"/index.html
  echo "</table>" >> "$HTML"/index.html
  echo "</body></html>" >> "$HTML"/index.html
  
  cd /var/www/html/ || return
  sudo chmod -R 755 .
  sudo cp -r "$SCREENSHOTS" /var/www/html/$domain/screenshots
  sudo cp "$HTML"/index.html /var/www/html/$domain/index.html
  cd "$HOME" || return
  echo -e "[$GREEN+$RESET] Scan finished"
  echo -e "[$GREEN+$RESET] Results page: http://$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')/$domain/"
  echo -e "[$GREEN+$RESET] Results page: http://$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')/$domain/screenshots/aquatone_report.html"
}

: 'Execute the main functions'
displayLogo
checkArguments
checkDirectories
gatherSubdomains
checkTakeovers
gatherResolvers
gatherIPs
gatherScreenshots
startBruteForce
makeHtml
### todo
#   startCors
#   startMeg
#   Startlinkfinder
