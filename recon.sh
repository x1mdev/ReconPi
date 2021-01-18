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
RESULTDIR="$HOME/assets/$domain"
WORDLIST="$RESULTDIR/wordlists"
SCREENSHOTS="$RESULTDIR/screenshots"
SUBS="$RESULTDIR/subdomains"
GFSCAN="$RESULTDIR/gfscan"
IPS="$RESULTDIR/ips"
PORTSCAN="$RESULTDIR/portscan"
ARCHIVE="$RESULTDIR/archive"
VERSION="2.3"
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
		echo -e "[$GREEN+$RESET] Creating directories and grabbing wordlists for $GREEN$domain$RESET.."
		mkdir -p "$RESULTDIR"
		mkdir -p "$SUBS" "$SCREENSHOTS" "$WORDLIST" "$IPS" "$PORTSCAN" "$ARCHIVE" "$NUCLEISCAN" "$GFSCAN"
}

startFunction() {
	tool=$1
	echo -e "[$GREEN+$RESET] Starting $tool"
}

: 'Gather resolvers'
gatherResolvers() {
	startFunction "Downloading fresh resolvers"
	wget https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt -O "$IPS"/resolvers.txt
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
	"$HOME"/go/bin/subfinder -d "$domain" -all -config "$HOME"/ReconPi/configs/config.yaml -o "$SUBS"/subfinder.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "assetfinder"
	"$HOME"/go/bin/assetfinder --subs-only "$domain" >"$SUBS"/assetfinder.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "amass"
	"$HOME"/go/bin/amass enum -passive -d "$domain" -config "$HOME"/ReconPi/configs/config.ini -o "$SUBS"/amassp.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "findomain"
	findomain -t "$domain" -u "$SUBS"/findomain_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "chaos"
	chaos -d "$domain" -key $CHAOS_KEY -o "$SUBS"/chaos_data.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "github-subdomains"
	github-subdomains -t $github_subdomains_token -d "$domain" | sort -u >> "$SUBS"/github_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	startFunction "rapiddns"
	crobat -s "$domain" | sort -u | tee "$SUBS"/rapiddns_subdomains.txt
	echo -e "[$GREEN+$RESET] Done, next."

	echo -e "[$GREEN+$RESET] Combining and sorting results.."
	cat "$SUBS"/*.txt | sort -u >"$SUBS"/subdomains

	#echo -e "[$GREEN+$RESET] Resolving subdomains.." # skip for now, httpx will resolve?
	#cat "$SUBS"/subdomains-enum | shuffledns -silent -d "$domain" -r "$IPS"/resolvers.txt > "$SUBS"/alive_subdomains
	echo -e "[$GREEN+$RESET] Getting alive hosts.." # check this part (httpx?)
	#new# maybe more ports with httpx?
	httpx -l "$SUBS"/subdomains -silent -threads 9000 -timeout 30 | anew "$SUBS"/hosts
	#old# cat "$SUBS"/alive_subdomains | "$HOME"/go/bin/httprobe -prefer-https | tee "$SUBS"/hosts
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

	startFunction "nuclei subdomain takeover check"
	nuclei -l "$SUBS"/hosts -t takeovers/ -c 50 -o "$SUBS"/nuclei-takeover-checks.txt
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
	cat "$SUBS"/subdomains | dnsprobe -r CNAME -o "$SUBS"/subdomains_cname.txt
}

: 'Gather IPs with dnsprobe'
gatherIPs() {
	startFunction "dnsprobe"
	cat "$SUBS"/subdomains | dnsprobe -silent -f ip | sort -u | tee "$IPS"/"$domain"-ips.txt
	python3 $HOME/ReconPi/scripts/clean_ips.py "$IPS"/"$domain"-ips.txt "$IPS"/"$domain"-origin-ips.txt
	echo -e "[$GREEN+$RESET] Done."
}

# check this. also, when running this it takes a lot of time (-p -), even with 4 ports)
: 'Portscan on found IP addresses'
portScan() {
	startFunction  "Port Scan"
	cd "$PORTSCAN" || return
	cat "$IPS"/"$domain"-origin-ips.txt | naabu -p - -silent -exclude-cdn -nmap -config "$HOME"/ReconPi/configs/naabu.conf -o "$PORTSCAN"/naabu
    mv reconpi-nmap* "$PORTSCAN"
	cd - || return
	echo -e "[$GREEN+$RESET] Port Scan finished"
}

: 'Use aquatone to gather screenshots'
gatherScreenshots() {
	startFunction "aquatone"
    cat "$SUBS"/hosts | aquatone -http-timeout 10000 -ports xlarge -out "$SCREENSHOTS"
	echo -e "[$GREEN+$RESET] Aquatone finished"
}

fetchArchive() {
	startFunction "fetchArchive"
	cat "$SUBS"/hosts | sed 's/https\?:\/\///' | gau > "$ARCHIVE"/getallurls.txt
	cat "$ARCHIVE"/getallurls.txt  | sort -u | unfurl --unique keys > "$ARCHIVE"/paramlist.txt
	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.js(\?|$)" | httpx -silent -status-code -mc 200 | awk '{print $1}' | sort -u > "$ARCHIVE"/jsurls.txt
	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.php(\?|$) | httpx -silent -status-code -mc 200 | awk '{print $1}' | sort -u " > "$ARCHIVE"/phpurls.txt
	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.aspx(\?|$) | httpx -silent -status-code -mc 200 | awk '{print $1}' | sort -u " > "$ARCHIVE"/aspxurls.txt
	cat "$ARCHIVE"/getallurls.txt  | sort -u | grep -P "\w+\.jsp(\?|$) | httpx -silent -status-code -mc 200 | awk '{print $1}' | sort -u " > "$ARCHIVE"/jspurls.txt
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

#this is a bit messy
: 'Check open redirects'
startOpenRedirect() {
	startFunction "gf open redirect"
	cat "$SUBS"/hosts | waybackurls | httpx -silent -timeout 2 -threads 100 | gf redirect | anew "$RESULTDIR"/openredirects.txt 
	cd "$HOME" || return
}

: 'directory brute-force'
startBruteForce() {
	startFunction "directory brute-force"
	# maybe run with interlace? Might remove
	cat "$SUBS"/hosts | parallel -j 5 --bar --shuf gobuster dir -u {} -t 50 -w wordlist.txt -l -e -r -k -q -o "$DIRSCAN"/"$sub".txt
	"$HOME"/go/bin/gobuster dir -u "$line" -w "$WORDLIST"/wordlist.txt -e -q -k -n -o "$DIRSCAN"/out.txt
}

: 'Use gf to find secrets in responses'
startGfScan() {
	startFunction "Checking for secrets using gf"
	cd "$SUBS"/meg || return
	for i in `gf -list`; do [[ ${i} =~ "_secrets"* ]] && gf ${i} >> "$GFSCAN"/"${i}".txt; done
	cd "$HOME" || return
}

: 'Check for Vulnerabilities'
runNuclei() {
	startFunction  "Nuclei CVEs Detection"
	nuclei -l "$SUBS"/hosts -t cves/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/cve.txt
	startFunction  "Nuclei Vulnerabilties Check"
	nuclei -l "$SUBS"/hosts -t vulnerabilities/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/vulnerabilties.txt
	startFunction  "Nuclei default logins Check"
	nuclei -l "$SUBS"/hosts -t default-logins/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/default-logins.txt
	startFunction  "Nuclei exposures Check"
	nuclei -l "$SUBS"/hosts -t exposures/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/exposures.txt
	startFunction  "Nuclei miscellaneous check"
	nuclei -l "$SUBS"/hosts -t miscellaneous/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/miscellaneous.txt
	startFunction  "Nuclei Panels Check"
	nuclei -l "$SUBS"/hosts -t exposed-panels/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/panels.txt
	startFunction  "Nuclei Misconfiguration Check"
	nuclei -l "$SUBS"/hosts -t misconfiguration/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/misconfiguration.txt
	startFunction  "Nuclei Technologies Check"
	nuclei -l "$SUBS"/hosts -t technologies/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/technologies.txt
	startFunction  "Nuclei Tokens Check"
	nuclei -l "$SUBS"/hosts -t exposed-tokens/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/tokens.txt
	startFunction  "Nuclei dns check"
	nuclei -l "$SUBS"/hosts -t dns/ -c 50 -H "x-bug-bounty: $hackerhandle" -o "$NUCLEISCAN"/dns.txt
	echo -e "[$GREEN+$RESET] Nuclei Scan finished"
}

notifySlack() {
	startFunction "Slack Notifications"
	source "$HOME"/ReconPi/configs/tokens.txt
	export SLACK_WEBHOOK_URL="$SLACK_WEBHOOK_URL"
	echo -e "ReconPi $domain scan completed!" | slackcat -c scanner -s -u ReconPi -t
	totalsum=$(cat $SUBS/hosts | wc -l)
	echo -e "$totalsum live subdomain hosts discovered" | slackcat -c scanner -s -u ReconPi -t

	# maybe add the results from gfscan as well

	posibbletko="$(cat $SUBS/takeovers | wc -l)"
	if [ -s "$SUBS/takeovers" ]
		then
        echo -e "Found $posibbletko possible subdomain takeovers." | slackcat -c scanner -s -u ReconPi -t
	else
        echo "No subdomain takeovers found." | slackcat -c scanner -s -u ReconPi -t
	fi

	if [ -f "$NUCLEISCAN/cve.txt" ]; then
	echo "CVE's discovered:" | slackcat -c scanner -s -u ReconPi -t
    cat "$NUCLEISCAN/cve.txt" | slackcat -c scanner -s -u ReconPi -t
		else 
    echo -e "No CVE's discovered." | slackcat -c scanner -s -u ReconPi -t
	fi

	if [ -f "$NUCLEISCAN/exposures.txt" ]; then
	echo "exposures discovered:" | slackcat -c scanner -s -u ReconPi -t
    cat "$NUCLEISCAN/exposures.txt" | slackcat -c scanner -s -u ReconPi -t
		else 
    echo -e "No exposures discovered." | slackcat -c scanner -s -u ReconPi -t
	fi

	if [ -f "$NUCLEISCAN/miscellaneous.txt" ]; then
	echo "miscellaneous stuff discovered:" | slackcat -c scanner -s -u ReconPi -t
    cat "$NUCLEISCAN/miscellaneous.txt" | slackcat -c scanner -s -u ReconPi -t
		else 
    echo -e "No miscellaneous stuff discovered." | slackcat -c scanner -s -u ReconPi -t
	fi

	if [ -f "$NUCLEISCAN/vulnerabilties.txt" ]; then
	echo "vulnerabilties discovered:" | slackcat -c scanner -s -u ReconPi -t
    cat "$NUCLEISCAN/vulnerabilties.txt" | slackcat -c scanner -s -u ReconPi -t
		else 
    echo -e "No vulnerabilties discovered." | slackcat -c scanner -s -u ReconPi -t
	fi

	if [ -f "$NUCLEISCAN/default-logins.txt" ]; then
	echo "default logins discovered:" | slackcat -c scanner -s -u ReconPi -t
    cat "$NUCLEISCAN/default-logins.txt" | slackcat -c scanner -s -u ReconPi -t
		else 
    echo -e "No default logins discovered." | slackcat -c scanner -s -u ReconPi -t
	fi

	echo -e "[$GREEN+$RESET] Done."

}

# difference between slack and discord?

notifyDiscord() {
	startFunction "Trigger Discord Notification"
	intfiles=$(cat $NUCLEISCAN/*.txt | wc -l)

	source "$HOME"/ReconPi/configs/tokens.txt
	export DISCORD_WEBHOOK_URL="$DISCORD_WEBHOOK_URL"

	totalsum=$(cat $SUBS/hosts | wc -l)
	message="**$domain scan completed!\n $totalsum live hosts discovered.**\n"

	if [ -s "$SUBS/takeovers" ]
	then
			posibbletko="$(cat $SUBS/takeovers | wc -l)"
			message+="**Found $posibbletko possible subdomain takeovers.**\n"
	else
			message+="**No subdomain takovers found.**\n"
	fi

	cd $NUCLEISCAN
	for file in *.txt
	do
		if [ -s "$file" ]
		then
			fileName=$(basename ${file%%.*})
			fileNameUpper="$(tr '[:lower:]' '[:upper:]' <<< ${fileName:0:1})${fileName:1}"
			nucleiData="$(jq -Rs . <$file | cut -c 2- | rev | cut -c 2- | rev)"
			message+="**$fileNameUpper discovered:**\n "$nucleiData"\n"
		fi
	done

	python3 $HOME/ReconPi/scripts/webhook_Discord.py <<< $(echo "$message")

	echo -e "[$GREEN+$RESET] Done."
}

: 'Execute the main functions'

source "$HOME"/ReconPi/configs/tokens.txt || return
export SLACK_WEBHOOK_URL="$SLACK_WEBHOOK_URL"

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
#startOpenRedirect work in progress
startGfScan
runNuclei
#portScan disabled this for now
#makePage
notifySlack
#notifyDiscord 
### Uncomment notigyDiscord to use it, vice versa for notifySlack

# Uncomment the functions
