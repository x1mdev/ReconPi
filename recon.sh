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
SUBS="$RESULTDIR/subdomains"
DIRSCAN="$RESULTDIR/directories"
HTML="$RESULTDIR/html"
IPS="$RESULTDIR/ips"
PORTSCAN="$RESULTDIR/portscan"
ARCHIVE="$RESULTDIR/archive"
VERSION="2.1"
NUCLEISCAN="$RESULTDIR/nucleiscan"
SHODANSCAN="$RESULTDIR/shodanscan"


: 'Display the logo'
displayLogo() {
	echo -e "
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                            
			v$VERSION - $YELLOW@x1m_martijn$RESET" 
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
		mkdir -p "$SUBS" "$SCREENSHOTS" "$DIRSCAN" "$HTML" "$WORDLIST" "$IPS" "$PORTSCAN" "$ARCHIVE" "$NUCLEISCAN" "$SHODANSCAN"
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
	#"$HOME"/go/bin/amass enum -active -d "$domain" -o "$SUBS"/amass.txt
	# Passive amass
	"$HOME"/go/bin/amass enum -passive -d "$domain" -o "$SUBS"/amassp.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "findomain"
	findomain -t "$domain" -u "$SUBS"/findomain_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "github-subdomains"
	python3 "$HOME"/tools/github-subdomains.py -t $github_subdomains_token -d "$domain" | sort -u >> "$SUBS"/github_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "Starting bufferover"
	curl "http://dns.bufferover.run/dns?q=$1" --silent | jq '.FDNS_A | .[]' -r 2>/dev/null | cut -f 2 -d',' | sort -u >> "$SUBS"/bufferover_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "Get Probable Permutation of Domain"
	for sub in $(cat $HOME/ReconPi/wordlists/subdomains.txt); do echo $sub.$domain >> "$SUBS"/commonspeak_subdomains.txt ; done
	echo -e "[$GREEN+$RESET] Done, next."

	echo -e "[$GREEN+$RESET] Combining and sorting results.."
	cat "$SUBS"/*.txt | sort -u >"$SUBS"/subdomains
	echo -e "[$GREEN+$RESET] Resolving subdomains.."
	cat "$SUBS"/subdomains | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt -o "$SUBS"/alive_subdomains
	rm "$SUBS"/subdomains
	echo -e "[$GREEN+$RESET] Running dnsgen to mutate subdomains.."
	cat "$SUBS"/alive_subdomains | dnsgen - | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt -o "$SUBS"/dnsgen.txt
	cat "$SUBS"/dnsgen.txt | sort -u >> "$SUBS"/alive_subdomains
	# Get http and https hosts
	echo -e "[$GREEN+$RESET] Getting alive hosts.."
	cat "$SUBS"/alive_subdomains | "$HOME"/go/bin/httprobe -prefer-https | tee "$SUBS"/hosts
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

	startFunction "nuclei to check takeover"
	cat "$SUBS"/hosts | nuclei -t "$HOME"/tools/nuclei-templates/subdomain-takeover/ -o "$SUBS"/nuclei-takeover-checks.txt
	vulnto=$(cat "$SUBS"/nuclei-takeover-checks.txt)
	if [[ $vulnto != "" ]]; then
		echo -e "[$GREEN+$RESET] Possible subdomain takeovers:"
		for line in "$SUBS"/nuclei-takeover-checks.txt; do
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

: 'Gather IPs with dnsprobe'
gatherIPs() {
	startFunction "dnsprobe"
	cat "$SUBS"/alive_subdomains | dnsprobe -silent -f ip | tee "$IPS"/"$domain"-ips.txt
	cat "$IPS"/"$domain"-ips.txt | cf-check | sort -u > "$IPS"/"$domain"-origin-ips.txt
	echo -e "[$GREEN+$RESET] Done."
}

: 'Portscan on found IP addresses'
portScan() {
	for line in $(cat "$IPS"/"$domain"-origin-ips.txt); do
	        /usr/local/bin/masscan -p 1-65535 --rate 5000 --wait 0 --open $line -oG "$PORTSCAN"/masscan
		ports=$(cat "$PORTSCAN"/masscan | grep -Eo "Ports:.[0-9]{1,5}" | cut -c 8- | sort -u | paste -sd,)
		nmap -sCV --script vulners,http-title -p $ports --open -Pn -T4 $line -oA "$PORTSCAN"/$line-nmap --max-retries 3
	done
}

: 'Use aquatone+chromium-browser to gather screenshots'
gatherScreenshots() {
	startFunction "aquatone"
	"$HOME"/go/bin/aquatone -http-timeout 10000 -out "$SCREENSHOTS" <"$SUBS"/hosts
}

fetchArchive() {
	startFunction "fetchArchive"
	cat "$SUBS"/hosts | sed 's/https\?:\/\///' | gau > "$ARCHIVE"/getallurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | unfurl --unique keys > "$ARCHIVE"/paramlist.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > "$ARCHIVE"/jsurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.php(\?|$) | sort -u " > "$ARCHIVE"/phpurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.aspx(\?|$) | sort -u " > "$ARCHIVE"/aspxurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.jsp(\?|$) | sort -u " > "$ARCHIVE"/jspurls.txt
}

fetchEndpoints() {
	startFunction "fetchEndpoints"
	for js in `cat "$ARCHIVE"/jsurls.txt`;
	do
		python3 "$HOME"/tools/LinkFinder/linkfinder.py -i $js -o cli | anew "$ARCHIVE"/endpoints.txt;
	done
}
: 'Gather information with meg'
startMeg() {
	startFunction "meg"
	cd "$SUBS" || return
	meg -d 1000 -v /
	mv out meg
	cd "$HOME" || return
}

: 'directory brute-force'
startBruteForce() {
	startFunction "directory brute-force"
	# maybe run with interlace? Might remove
	cat "$SUBS"/hosts | parallel -j 5 --bar --shuf gobuster dir -u {} -t 50 -w wordlist.txt -l -e -r -k -q -o "$DIRSCAN"/"$sub".txt
	"$HOME"/go/bin/gobuster dir -u "$line" -w "$WORDLIST"/wordlist.txt -e -q -k -n -o "$DIRSCAN"/out.txt
}
: 'Check for Vulnerabilities'
runNuclei() {
	startFunction "Starting Nuclei Basic-detections"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/basic-detections/ -o "$NUCLEISCAN"/basic-detections.txt
	startFunction "Starting Nuclei CVEs Detection"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/cves/ -o "$NUCLEISCAN"/cve.txt
	startFunction "Starting Nuclei dns check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/dns/ -o "$NUCLEISCAN"/dns.txt
	startFunction "Starting Nuclei files check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/files/ -o "$NUCLEISCAN"/files.txt
	startFunction "Starting Nuclei Panels Check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/panels/ -o "$NUCLEISCAN"/panels.txt
	startFunction "Starting Nuclei Security-misconfiguration Check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/security-misconfiguration/ -o "$NUCLEISCAN"/security-misconfiguration.txt
	startFunction "Starting Nuclei Technologies Check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/technologies/ -o "$NUCLEISCAN"/technologies.txt
	startFunction "Starting Nuclei Tokens Check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/tokens/ -o "$NUCLEISCAN"/tokens.txt
	startFunction "Starting Nuclei Vulnerabilties Check"
	nuclei -l "$SUBS"/hosts -t "$HOME"/tools/nuclei-templates/vulnerabilities/ -o "$NUCLEISCAN"/vulnerabilties.txt
	echo -e "[$GREEN+$RESET] Nuclei Scan finished"
}

checkShodan() {
	startFunction "Checking Resolved IPs on Shodan"
	cat "$IPS"/"$domain"-origin-ips.txt | sort -u | python3 "$HOME"/tools/Shodanfy.py/shodanfy.py --stdin --getvuln --getports --getinfo --getbanner | tee "$SHODANSCAN"/shodanfy.txt

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

notifySlack() {
	startFunction "Trigger Slack Notification"
	ip_add=$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
	takeover="$(cat $SUBS/takeovers)"
	hosts="$(cat $SUBS/hosts)"
	nucleiScan="$(cat $NUCLEISCAN/*)"
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## ReconPi finished scanning: $domain ##'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Screenshots for $domain completed! ##\n http://$ip_add/$domain/screenshots/aquatone_report.html'}" $slack_url 2 > /dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Subdomain Takeover for $domain ##\n $takeover'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Hosts Discovered for $domain ##\n $hosts'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Nuclei Scan for $domain ##\n $nucleiScan'}" $slack_url 2>/dev/null
	echo -e "[$GREEN+$RESET] Done."
}

: 'Execute the main functions'

source "$HOME"/ReconPi/tokens.txt

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
#fetchArchive
#fetchEndpoints
runNuclei
checkShodan
#portScan
makePage
notifySlack
