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
PORTSCAN="$RESULTDIR/portscan"
ARCHIVE="$RESULTDIR/archive"
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
    echo -e "[$GREEN+$RESET] Creating directories and grabbing wordlists for $GREEN$domain$RESET.."
    mkdir -p "$RESULTDIR"
    mkdir -p "$SUBS" "$CORS" "$SCREENSHOTS" "$DIRSCAN" "$HTML" "$WORDLIST" "$IPS" "$PORTSCAN" "$ARCHIVE"
    sudo mkdir -p /var/www/html/"$domain"
    cp "$BASE"/wordlists/*.txt "$WORDLIST"
  fi
}

startFunction() {
  tool=$1
  echo -e "[$GREEN+$RESET] Starting $tool"
}

: 'Gather resolvers with bass'
gatherResolvers() {
  startFunction "bass (resolvers)"
  cd "$HOME"/tools/bass || return
  python3 bass.py -d "$domain" -o "$IPS"/resolvers.txt
}

: 'subdomain gathering'
gatherSubdomains() {
  startFunction "sublert"
  echo -e "[$GREEN+$RESET] Checking for existing sublert output, otherwise add it."
  if [ ! -e "$SUBS"/sublert.txt ]; then
    cd "$HOME"/tools/sublert || return
    yes | python3 sublert.py -u "$domain"
    cp "$HOME"/tools/sublert/output/"$domain".txt "$SUBS"/sublert.txt
    cd "$HOME" || return
  else
    cp "$HOME"/tools/sublert/output/"$domain".txt "$SUBS"/sublert.txt
  fi
  echo -e "[$GREEN+$RESET] Done, next."

  startFunction "subfinder"
  "$HOME"/go/bin/subfinder -d "$domain" -v -exclude-sources dnsdumpster -o "$SUBS"/subfinder.txt
  echo -e "[$GREEN+$RESET] Done, next."

  startFunction "assetfinder"
  "$HOME"/go/bin/assetfinder --subs-only "$domain" >"$SUBS"/assetfinder.txt
  echo -e "[$GREEN+$RESET] Done, next."

  startFunction "amass"
# Active amass
  "$HOME"/go/bin/amass enum -active -d "$domain" -o "$SUBS"/amass.txt
# Passive amass
  "$HOME"/go/bin/amass enum -passive -d "$domain" -o "$SUBS"/amassp.txt

  echo -e "[$GREEN+$RESET] Done, next."

  echo -e "[$GREEN+$RESET] Combining and sorting results.."
  cat "$SUBS"/*.txt | sort -u >"$SUBS"/subdomains
  cat "$SUBS"/subdomains | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt -o "$SUBS"/alive_subdomains
  rm "$SUBS"/subdomains
  cat "$SUBS"/alive_subdomains | dnsgen - | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt -o "$SUBS"/dnsgen.txt
  cat "$SUBS"/dnsgen.txt | sort -u >> "$SUBS"/alive_subdomains
# Get http and https hosts
  "$HOME"/go/bin/httprobe <"$SUBS"/alive_subdomains | tee "$SUBS"/hosts
  echo -e "[$GREEN+$RESET] Done."
}

: 'subdomain takeover check'
checkTakeovers() {
  startFunction "subjack"
  "$HOME"/go/bin/subjack -w "$SUBS"/hosts -a -ssl -t 50 -v -c "$HOME"/go/src/github.com/haccer/subjack/fingerprints.json -o "$SUBS"/all-takeover-checks.txt -ssl
  grep -v "Not Vulnerable" <"$SUBS"/all-takeover-checks.txt >"$SUBS"/takeovers
  rm "$SUBS"/all-takeover-checks.txt

  vulnto=$(cat "$SUBS"/takeovers)
  if [[ $vulnto == *i* ]]; then
    echo -e "[$GREEN+$RESET] Possible subdomain takeovers:"
    for line in "$SUBS"/takeovers; do
      echo -e "[$GREEN+$RESET] --> $vulnto "
    done
  else
    echo -e "[$GREEN+$RESET] No takeovers found."
  fi
}

: 'Get all CNAME'
getCNAME() {
  startFunction "dnsprobe to get CNAMEs"
  cat "$SUBS"/alive_subdomains | dnsprobe -r CNAME -o "$SUBS"/subdomains_cname.txt
}
: 'Gather IPs with massdns'
gatherIPs() {
  startFunction "massdns"
  /usr/local/bin/massdns -r "$IPS"/resolvers.txt -q -t A -o S -w "$IPS"/massdns.raw "$SUBS"/alive_subdomains
  cat "$IPS"/massdns.raw | grep -e ' A ' | cut -d 'A' -f 2 | tr -d ' ' >"$IPS"/massdns.txt
  sort -u <"$IPS"/massdns.txt >"$IPS"/"$domain"-ips.txt
  rm "$IPS"/massdns.raw
  echo -e "[$GREEN+$RESET] Done."
}

: 'Portscan on found IP addresses'
portScan() {
  /usr/local/bin/masscan -p 1-65535 --rate 10000 --wait 0 --open -iL "$IPS"/"$domain"-ips.txt -oG "$PORTSCAN"/masscan
  for line in $(cat "$IPS"/"$domain"-ips.txt); do
    ports=$(cat "$PORTSCAN"/masscan | grep -Eo "Ports:.[0-9]{1,5}" | cut -c 8- | sort -u | paste -sd,)
   nmap -sCV --script vulners -p $ports --open -Pn -T4 $line -oA "$PORTSCAN"/$line-nmap --max-retries 3
  done
}

: 'Use aquatone+chromium-browser to gather screenshots'
gatherScreenshots() {
  startFunction "aquatone"
  "$HOME"/go/bin/aquatone -http-timeout 10000 -out "$SCREENSHOTS" <"$SUBS"/hosts
}

fetchArchive() {
  startFunction "fetchArchive"
  cat "$SUBS"/hosts | gau > "$ARCHIVE"/getallurls.txt

  cat "$ARCHIVE"/getallurls.txt  | sort -u | unfurl --unique keys > "$ARCHIVE"/paramlist.txt

  cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > "$ARCHIVE"/jsurls.txt

  cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.php(\?|$) | sort -u " > "$ARCHIVE"/phpurls.txt

  cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.aspx(\?|$) | sort -u " > "$ARCHIVE"/aspxurls.txt

  cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.jsp(\?|$) | sort -u " > "$ARCHIVE"/jspurls.txt
}

: 'Gather information with meg'
startMeg() {
  startFunction "meg"
  cd "$SUBS" || return
  meg -d 1000 -v /
  mv out meg
  cd "$HOME" || return
}

: 'Use the CORScanner to check for CORS misconfigurations'
checkCORS() {
  startFunction "CORScanner"
  python3 "$HOME"/tools/CORScanner/cors_scan.py -v -t 50 -i "$SUBS"/hosts | tee "$CORS"/cors.txt
  echo -e "[$GREEN+$RESET] Done."
}
: 'directory brute-force'
startBruteForce() {
  startFunction "directory brute-force"
  # maybe run with interlace? Might remove
cat "$SUBS"/hosts | parallel -j 5 --bar --shuf gobuster dir -u {} -t 50 -w wordlist.txt -l -e -r -k -q -o "$DIRSCAN"/"$sub".txt
    "$HOME"/go/bin/gobuster dir -u "$line" -w "$WORDLIST"/wordlist.txt -e -q -k -n -o "$DIRSCAN"/out.txt
}

: 'Setup aquatone results one the ReconPi IP address'
makePage() {
  startFunction "HTML webpage"
  cd /var/www/html/ || return
  sudo chmod -R 755 .
  sudo cp -r "$SCREENSHOTS" /var/www/html/$domain
  sudo chmod a+r -R /var/www/html/$domain/*
  cd "$HOME" || return
  echo -e "[$GREEN+$RESET] Scan finished, start doing some manual work ;)"
  echo -e "[$GREEN+$RESET] The aquatone results page and the meg results directory are great starting points!"
  echo -e "[$GREEN+$RESET] Aquatone results page: http://$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)/$domain/screenshots/aquatone_report.html"
  echo -e "[$GREEN+$RESET]Now manually do all JS Analysis (https://github.com/dark-warlord14/JSScanner)"
  echo -e "[$GREEN+$RESET]Also Don't forget Directory brutefocing"
}

: 'Execute the main functions'
displayLogo
checkArguments
checkDirectories
gatherResolvers
gatherSubdomains
checkTakeovers
getCNAME
gatherIPs
gatherScreenshots
startMeg
fetchArchive
portScan
makePage
