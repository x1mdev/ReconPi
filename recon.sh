#!/bin/bash
: '
	@name   ReconPi recon.sh
	@author Martijn Baalman <@x1m_martijn>
	@link   https://github.com/x1mdev/ReconPi
'


: 'Set the main variables'
YELLOW="\033[1;33m"
GREEN="\033[0;32m"
RESET="\033[0m"
ROOT="$HOME/bugbounty"
FILE=`basename "$0"`
VERSION="0.2.1"


: 'Display the logo'
displayLogo()
{
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
checkArguments()
{
	if [[ -z $1 ]]; then
		echo -e "[$GREEN+$RESET] Usage: bash $FILE <domain.tld>"
		exit 1
	fi
}

: 'Check if the current domain has a directory, else make it'
checkDirectory()
{
	if [ ! -d $ROOT ]; then
		echo -e "[$GREEN+$RESET] Creating new directory: $GREEN$ROOT$RESET"
		mkdir "$ROOT"
		cd $ROOT
	fi
	if [ ! -d $ROOT/$1 ]; then
		echo -e "[$GREEN+$RESET] Creating new directory: $GREEN$ROOT/$1$RESET"
		mkdir -p "$ROOT/$1"
		cd $ROOT/$1
	fi
}

: 'Run Subfinder on the given domain'
runSubfinder()
{
	echo -e "[$GREEN+$RESET] Running Subfinder on $GREEN$1$RESET..."
	subfinder -d $1 -nW --silent > $ROOT/$1/$1.txt

	echo -e "[$GREEN+$RESET] Subfinder finished! Writing (sub)domains to $GREEN$ROOT/$1/domains.txt$RESET."
	touch $ROOT/$1/domains.txt
	cat $ROOT/$1/$1.txt | grep -P "([A-Za-z0-9]).*$1" >> $ROOT/$1/domains.txt

	rm -rf $ROOT/$1/$1.txt
}

# Get subfinder output that is in the Aquatone format to run it in Aquatone

: 'Check if host is online, then print it'
checkDomainStatus()
{
	echo -e "[$GREEN+$RESET] Checking which domains are online..."

	touch "$ROOT"/"$1"/resolved-domains.txt

	while IFS='' read -r line || [[ -n "$line" ]]; do
		if ping -c 1 "$(echo "$line" | tr -d '[:space:]')" &> /dev/null
		then
			IP=`getent hosts "$1" | cut -d' ' -f1 | head -n 1`
			echo "$(echo "$line" | tr -d '[:space:]'),$IP"
		fi
	done < "$ROOT"/"$1"/domains.txt > "$ROOT"/"$1"/resolved-domains.txt

	echo -e "[$GREEN+$RESET] Online domains written to $GREEN$ROOT/$1/resolved-domains.txt$RESET!"
	echo -e "[$GREEN+$RESET] Displaying $GREEN$ROOT/$1/resolved-domains.txt$RESET:"
	cat "$ROOT"/"$1"/resolved-domains.txt
}

: 'Run MassDNS on the given domains'
runMassDNS()
{
	echo -e "[$GREEN+$RESET] Starting MassDNS now!"
	massdns -r $HOME/tools/massdns/lists/resolvers.txt -t A -o S -w $ROOT/$1/resolved-domains.txt > $ROOT/$1/massdns.txt
	echo -e "[$GREEN+$RESET] Done!"
}

: 'Convert domains.txt to json (subdomainDB format) + make POST API request with output from subfinder'
convertDomainsFile()
{
	echo -e "[$GREEN+$RESET] Converting $GREEN$ROOT/$1/domains.txt$RESET to an acceptable $GREEN.json$RESET file.."
	cat $ROOT/$1/domains.txt | grep -P "([A-Za-z0-9]).*$1" >> $ROOT/$1/domains.json
	echo -e "{\\n\"domains\":"; jq -MRs 'split("\n")' < domains.json | sed -z 's/,\n  ""//g'; echo -e "}"
	
	# TODO: Post request to dashboard - work in progress
	#curl -X POST -H "Content-Type: application/json" -H "X-Hacking: is Illegal!" -d "@domains.json" http://127.0.0.1:4000/api/domain/:domain

}

: 'Start up the dashboard server'
startDashboard()
{
	echo -e "[$GREEN+$RESET] Starting dashboard with results for $GREEN$1$RESET:"
	cd $HOME/ReconPi/dashboard/;
	go run server.go &;
	echo -e "[$GREEN+$RESET] Dashboard running on http://192.168.2.39:1337/"
	# TODO: Needs template rendering and json input from other functions
	# TODO: Check if server is running, otherwise skip this step.
	# TODO: Check if we can print out the correct IP address
}

: 'Execute the main functions'
displayLogo
checkArguments    		"$1"
checkDirectory    		"$1"
runSubfinder      		"$1"
checkDomainStatus 		"$1"
runMassDNS        		"$1"
convertDomainsFile 		"$1"
startDashboard 	   		"$1"
