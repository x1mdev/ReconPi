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
VERSION="1.1.0"


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
		echo -e "[$GREEN+$RESET] Usage: recon <domain.tld>"
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
}

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
	massdns -r $HOME/tools/massdns/lists/resolvers.txt -t A -o S -w $ROOT/$1/massdns.txt $ROOT/$1/resolved-domains.txt
	echo -e "[$GREEN+$RESET] Done!"
}

: 'Convert domains.txt to json (subdomainDB format)'
convertDomainsFile()
{
	echo -e "[$GREEN+$RESET] Converting $GREEN$ROOT/$1/domains.txt$RESET to an acceptable $GREEN.json$RESET file.."
	cat $ROOT/$1/domains.txt | grep -P "([A-Za-z0-9]).*$1" >> $ROOT/$1/domains-striped.txt
	( echo -e "{\\n\"domains\":"; jq -MRs 'split("\n")' < $ROOT/$1/domains-striped.txt | sed -z 's/,\n  ""//g'; echo -e "}" ) &> $ROOT/$1/domains.json
}

: 'Start up the dashboard server'
startDashboard()
{
	echo -e "[$GREEN+$RESET] Starting dashboard and adding results for $GREEN$1$RESET:"
	docker run -d -v subdomainDB:/subdomainDB -p 0.0.0.0:4000:4000 subdomaindb
	sleep 10 # Required for the first run only, otherwise the POST request will be rejected.
	curl -X POST \
  	http://0.0.0.0:4000//api/domain/%20$1 \
  	-H 'cache-control: no-cache' \
  	-H 'content-type: application/json' \
  	-d @$ROOT/$1/domains.json
	echo -e "[$GREEN+$RESET] $1 scan results available on http://recon.pi.ip.address:4000"	
	
}

: 'Clean up'
cleanup()
{
	# TODO: Check if there are more useless files
	echo -e "[$GREEN+$RESET] Cleaning up.."
	rm $ROOT/$1/$1.txt
	rm $ROOT/$1/domains-striped.txt
	sleep 1
	echo -e "[$GREEN+$RESET] Done, ready for the next scan!"
}

: 'Execute the main functions'
displayLogo
checkArguments    		"$1"
checkDirectory    		"$1"
runSubfinder      		"$1"
checkDomainStatus 		"$1"
runMassDNS        		"$1" # something is up with massdns -> fixed with Re4son Kali Pi image :)
convertDomainsFile 		"$1"
startDashboard 	   		"$1"
cleanup					"$1"