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
		mkdir -p "$SUBS" "$SCREENSHOTS" "$DIRSCAN" "$HTML" "$WORDLIST" "$IPS" "$PORTSCAN" "$ARCHIVE" "$NUCLEISCAN"
		sudo mkdir -p /var/www/html/"$domain"
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
	"$HOME"/go/bin/subfinder -d "$domain" -config "$HOME"/ReconPi/configs/config.yaml -o "$SUBS"/subfinder.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "assetfinder"
	"$HOME"/go/bin/assetfinder --subs-only "$domain" >"$SUBS"/assetfinder.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "amass"
	# Active amass
	#"$HOME"/go/bin/amass enum -active -d "$domain" -o "$SUBS"/amass.txt
	# Passive amass
	"$HOME"/go/bin/amass enum -passive -d "$domain" -config "$HOME"/ReconPi/configs/config.ini -o "$SUBS"/amassp.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "findomain"
	findomain -t "$domain" -u "$SUBS"/findomain_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "chaos"
	chaos -d "$domain" -key $CHAOS_KEY -o "$SUBS"/chaos_data.txt
	echo -e "[$GREEN+$RESET] Done, next."

	# Github gives different result sometimes, so running multiple instances so that we don't miss any subdomain
	startFunction "github-subdomains"
	python3 "$HOME"/tools/github-subdomains.py -t $github_subdomains_token -d "$domain" | sort -u >> "$SUBS"/github_subdomains.txt
	sleep 5
	python3 "$HOME"/tools/github-subdomains.py -t $github_subdomains_token -d "$domain" | sort -u >> "$SUBS"/github_subdomains.txt
	sleep 5
	python3 "$HOME"/tools/github-subdomains.py -t $github_subdomains_token -d "$domain" | sort -u >> "$SUBS"/github_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "Starting bufferover"
	curl "http://dns.bufferover.run/dns?q=$domain" --silent | jq '.FDNS_A | .[]' -r 2>/dev/null | cut -f 2 -d',' | sort -u >> "$SUBS"/bufferover_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	#startFunction "Get Probable Permutation of Domain"
	#for sub in $(cat $HOME/ReconPi/wordlists/subdomains.txt); do echo $sub.$domain >> "$SUBS"/commonspeak_subdomains.txt ; done
	#echo -e "[$GREEN+$RESET] Done, next."

	echo -e "[$GREEN+$RESET] Combining and sorting results.."
	cat "$SUBS"/*.txt | sort -u >"$SUBS"/subdomains
	echo -e "[$GREEN+$RESET] Resolving subdomains.."
	cat "$SUBS"/subdomains | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt -o "$SUBS"/all_subdomains.txt
	# rm "$SUBS"/subdomains

	#all_subdomains="$(wc -l<"$SUBS"/all_subdomains.txt)"

	#If total alive subdomains are less than 500, run dnsgen otherwise altdns, this is done to keep script efficient.
	# if [ "$all_subdomains" -lt 500 ]; then
	# echo -e "[$GREEN+$RESET] Running dnsgen to mutate subdomains and resolving them.."
	# # cat "$SUBS"/all_subdomains.txt | dnsgen - | sort -u | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt -o "$SUBS"/dnsgen.txt
	# # cat "$SUBS"/dnsgen.txt | sort -u >> "$SUBS"/all_subdomains.txt
	# else
	# echo -e "[$GREEN+$RESET] Running altdns to mutate subdomains and resolving them.."
	# altdns -i "$SUBS"/all_subdomains.txt -w "$HOME"/ReconPi/wordlists/words_permutation.txt -o "$SUBS"/altdns.txt
	# cat "$SUBS"/altdns.txt | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt >> "$SUBS"/all_subdomains.txt
	# fi

	echo -e "[$GREEN+$RESET] Resolving All Subdomains.."
	cat "$SUBS"/all_subdomains.txt | sort -u | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt > "$SUBS"/alive_subdomains
	rm "$SUBS"/all_subdomains.txt
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
	cat "$SUBS"/hosts | nuclei -t "$HOME"/tools/nuclei-templates/subdomain-takeover/ -c 50 -o "$SUBS"/nuclei-takeover-checks.txt
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
	cat "$IPS"/"$domain"-ips.txt | cf-check -c 5 | sort -u > "$IPS"/"$domain"-origin-ips.txt
	echo -e "[$GREEN+$RESET] Done."
}

: 'Portscan on found IP addresses'
portScan() {
	startFunction "Starting Port Scan"
	cat "$IPS"/"$domain"-origin-ips.txt | naabu -silent | bash "$HOME"/tools/naabu2nmap.sh | tee "$PORTSCAN"/"$domain".nmap
	echo -e "[$GREEN+$RESET] Port Scan finished"
}

: 'Use aquatone+chromium-browser to gather screenshots'
gatherScreenshots() {
	startFunction "aquatone"
	"$HOME"/go/bin/aquatone -http-timeout 10000 -out "$SCREENSHOTS" <"$SUBS"/hosts
	echo -e "[$GREEN+$RESET] Aquatone finished"
}

fetchArchive() {
	startFunction "fetchArchive"
	cat "$SUBS"/hosts | sed 's/https\?:\/\///' | gau > "$ARCHIVE"/getallurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | unfurl --unique keys > "$ARCHIVE"/paramlist.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.js(\?|$)" | sort -u > "$ARCHIVE"/jsurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.php(\?|$) | sort -u " > "$ARCHIVE"/phpurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.aspx(\?|$) | sort -u " > "$ARCHIVE"/aspxurls.txt

	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.jsp(\?|$) | sort -u " > "$ARCHIVE"/jspurls.txt
	echo -e "[$GREEN+$RESET] fetchArchive finished"
}

fetchEndpoints() {
	startFunction "fetchEndpoints"
	for js in `cat "$ARCHIVE"/jsurls.txt`;
	do
		python3 "$HOME"/tools/LinkFinder/linkfinder.py -i $js -o cli | anew "$ARCHIVE"/endpoints.txt;
	done
	echo -e "[$GREEN+$RESET] fetchEndpoints finished"
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
	nuclei -l "$SUBS"/hosts -t basic-detections/ -c 50 -o "$NUCLEISCAN"/basic-detections.txt
	startFunction "Starting Nuclei Brute-force"
	nuclei -l "$SUBS"/hosts -t brute-force/ -c 50 -o "$NUCLEISCAN"/brute-force.txt
	startFunction "Starting Nuclei CVEs Detection"
	nuclei -l "$SUBS"/hosts -t cves/ -c 50 -o "$NUCLEISCAN"/cve.txt
	startFunction "Starting Nuclei dns check"
	nuclei -l "$SUBS"/hosts -t dns/ -c 50 -o "$NUCLEISCAN"/dns.txt
	startFunction "Starting Nuclei files check"
	nuclei -l "$SUBS"/hosts -t files/ -c 50 -o "$NUCLEISCAN"/files.txt
	startFunction "Starting Nuclei Panels Check"
	nuclei -l "$SUBS"/hosts -t panels/ -c 50 -o "$NUCLEISCAN"/panels.txt
	startFunction "Starting Nuclei Security-misconfiguration Check"
	nuclei -l "$SUBS"/hosts -t security-misconfiguration/ -c 50 -o "$NUCLEISCAN"/security-misconfiguration.txt
	startFunction "Starting Nuclei Technologies Check"
	nuclei -l "$SUBS"/hosts -t technologies/ -c 50 -o "$NUCLEISCAN"/technologies.txt
	startFunction "Starting Nuclei Tokens Check"
	nuclei -l "$SUBS"/hosts -t tokens/ -c 50 -o "$NUCLEISCAN"/tokens.txt
	startFunction "Starting Nuclei Vulnerabilties Check"
	nuclei -l "$SUBS"/hosts -t vulnerabilities/ -c 50 -o "$NUCLEISCAN"/vulnerabilties.txt
	echo -e "[$GREEN+$RESET] Nuclei Scan finished"
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
	echo -e "[$GREEN+$RESET] The aquatone results page, nuclei results directory and the meg results directory are great starting points!"
	echo -e "[$GREEN+$RESET] Aquatone results page: http://$(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)/$domain/screenshots/aquatone_report.html"
}

notifySlack() {
	startFunction "Trigger Slack Notification"
	takeover="$(cat $SUBS/takeovers | wc -l)"
	totalsum=$(cat $SUBS/hosts | wc -l)
  	intfiles=$(cat $NUCLEISCAN/*.txt | wc -l)
	nucleiCveScan="$(cat $NUCLEISCAN/cve.txt)"
	nucleiFileScan="$(cat $NUCLEISCAN/files.txt)"
	nucleiMisconfigureScan="$(cat $NUCLEISCAN/security-misconfiguration.txt)"
	nucleiTokenScan="$(cat $NUCLEISCAN/tokens.txt)"
	nucleiVulScan="$(cat $NUCLEISCAN/vulnerabilties.txt)"

	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## ReconPi finished scanning: $domain ##'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data '{"text":"Found '$totalsum' live hosts for '$domain'"}' $slack_url 2 > /dev/null
	curl -s -X POST -H 'Content-type: application/json' --data '{"text":"Found '$intfiles' interesting files using nuclei"}' $slack_url 2 > /dev/null
	curl -s -X POST -H 'Content-type: application/json' --data '{"text":"Found '$takeover' subdomain takeovers on '$domain'"}' $slack_url 2 > /dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Nuclei CVEs Scan for $domain ##\n $nucleiCveScan'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Nuclei Files Scan for $domain ##\n $nucleiFileScan'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Nuclei Security Misconfiguration Scan for $domain ##\n $nucleiMisconfigureScan'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Nuclei Tokens Scan for $domain ##\n $nucleiTokenScan'}" $slack_url 2>/dev/null
	curl -s -X POST -H 'Content-type: application/json' --data "{'text':'## Nuclei Vulnerabilities Scan for $domain ##\n $nucleiVulScan'}" $slack_url 2>/dev/null
	echo -e "[$GREEN+$RESET] Done."
}

: 'Execute the main functions'

source "$HOME"/ReconPi/configs/tokens.txt || return

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
fetchEndpoints
runNuclei
portScan
makePage
notifySlack
