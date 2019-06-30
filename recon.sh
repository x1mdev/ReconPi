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
BASE="$HOME/ReconPi"
domain="$1"
#ROOT="$HOME/bugbounty"
BASERESULT="$HOME/bugbounty"
RESULTDIR="$HOME/bugbounty/$domain"
VERSION="2.0"


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
	if [[ -z $domain ]]; then
		echo -e "[$GREEN+$RESET] Usage: recon <domain.tld>"
		exit 1
	fi
}

: 'Display help text when no arguments are given or do a big scan'
# need to do some work on this 
checkArguments2()
{
	while getopts ":a:" opt; do
  case $opt in
    a)
      echo "-a was triggered, Parameter: $OPTARG" >&2
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
}

: 'Check if the current domain has a directory, if not create it'
checkDirectory()
{
	if [ ! -d "$BASERESULT" ]; then
		echo -e "[$GREEN+$RESET] Creating new directory: $GREEN$BASERESULT$RESET"
		mkdir "$BASERESULT"
		#cd $RESULTDIR
	fi
}

checkDirectory2()
{
if [ ! -d "$RESULTDIR" ]; then
		echo -e "[$GREEN+$RESET] Creating new directory: $GREEN$RESULTDIR$RESET"
		mkdir -p "$RESULTDIR"
		#cd $ROOT/$domain
	fi
}

: 'bruteforce'
bruteForce()
{
  echo -e "[$GREEN+$RESET] Creating wordlists"
  ## Maybe set flag for more curated list options, depending on target
  bash "$BASE"/scripts/app_subs.sh "$BASE"/wordlists/commonspeak2-subdomains.txt "$domain" "$RESULTDIR/commonspeak-wordlist.txt"
  bash "$BASE"/scripts/app_subs.sh "$BASE"/wordlists/stackoverflow-subdomains.txt "$domain" "$RESULTDIR/stackoverflow-wordlist.txt"
  bash "$BASE"/scripts/app_subs.sh "$BASE"/wordlists/bitquark_subdomains_top100K.txt "$domain" "$RESULTDIR/bitquark-wordlist.txt"
  bash "$BASE"/scripts/app_subs.sh "$BASE"/wordlists/subdomains-top1mil-110000.txt "$domain" "$RESULTDIR/top1mil-wordlist.txt"
  bash "$BASE"/scripts/app_subs.sh "$BASE"/wordlists/subdomains.lst "$domain" "$RESULTDIR/subdomainslst-wordlist.txt"
  touch "$RESULTDIR"/subdomains.txt

  echo -e "[$GREEN+$RESET] Sorting and making combo list unique"
  cat "$RESULTDIR"/commonspeak-wordlist.txt "$RESULTDIR"/stackoverflow-wordlist.txt "$RESULTDIR"/bitquark-wordlist.txt "$RESULTDIR"/top1mil-wordlist.txt "$RESULTDIR"/subdomainslst-wordlist.txt >> "$RESULTDIR"/wordlist.txt
  sort -u "$RESULTDIR/wordlist.txt" -o "$RESULTDIR/wordlist.txt"

  echo -e "[$GREEN+$RESET] resolving subdomains.."
  "$HOME"/tools/massdns/bin/massdns -r "$BASE"/wordlists/resolvers.txt -q -t A -o S -w "$RESULTDIR/wordlist-online.txt" "$RESULTDIR/wordlist.txt"
  awk -F ". " '{print $domain}' "$RESULTDIR/wordlist-online.txt" > "$RESULTDIR/wordlist-filtered.txt" && mv "$RESULTDIR/wordlist-filtered.txt" "$RESULTDIR/wordlist-online.txt"
  echo -e "[$GREEN+$RESET] checking http & https"
  # touch "$RESULTDIR"/bruteforce-online.txt

  # while IFS='' read -r line || [[ -n "$line" ]]; do
	#   if ping -c 1 "$(echo "$line" | tr -d '[:space:]')" &> /dev/null
	#   then
	# 	  IP=$(getent hosts "$domain" | cut -d' ' -f1 | head -n 1)
	# 	  echo "$(echo "$line" | tr -d '[:space:]'),$IP" # misschien $ip eruit
	#   fi
  # done < "$RESULTDIR"/wordlist-online.txt > "$RESULTDIR"/bruteforce-online.txt

  cat "$RESULTDIR"/wordlist-online.txt | httprobe | tee "$RESULTDIR"/bruteforce-results.txt;
  cat "$RESULTDIR"/bruteforce-results.txt | grep -P "([A-Za-z0-9]).*$domain" >> "$RESULTDIR"/bruteforce-online.txt
}

: 'subfinder'
runSubfinder()
{
  echo -e "[$GREEN+$RESET] Running Subfinder"
  "$HOME"/go/bin/subfinder -d "$domain" -o "$RESULTDIR/subfinder-online.txt" -rL "$BASE"/wordlists/resolvers.txt
  echo -e "[$GREEN+$RESET] COMBINE & SORT SUBFINDER"
  cat "$RESULTDIR"/bruteforce-online.txt "$RESULTDIR"/subfinder-online.txt >> "$RESULTDIR"/subdomains.txt
  sort -u "$RESULTDIR/subdomains.txt" -o "$RESULTDIR/subdomains.txt"
}

: 'assetfinder'
runAssetfinder()
{
  echo -e "[$GREEN+$RESET] Running assetfinder"
  "$HOME"/go/bin/assetfinder --subs-only "$domain" > "$RESULTDIR/assetfinder-online.txt"
  echo -e "[$GREEN+$RESET] COMBINE & SORT assetfinder RESULTS"
  cat "$RESULTDIR"/assetfinder-online.txt >> "$RESULTDIR"/subdomains.txt
  sort -u "$RESULTDIR/subdomains.txt" -o "$RESULTDIR/subdomains.txt"
}

: 'amass'
runAmass()
{

  echo -e "[$GREEN+$RESET] AMASS"
  #touch "$RESULTDIR"/amass.txt

  ## -rf "$BASE"/wordlists/resolvers.txt
  ## werkt niet, to many output error
  "$HOME"/go/bin/amass -d "$domain" -o "$RESULTDIR/amass.txt"
  echo -e "[$GREEN+$RESET] CHECK AMASS"
  #touch "$RESULTDIR"/amass-online.txt
  #"$HOME"/tools/massdns/bin/massdns -r "$BASE"/wordlists/resolvers.txt -q -t A -o S -w "$RESULTDIR/amass-domains.txt" "$RESULTDIR/amass.txt"
  #sed 's#^#http://#g' $ROOT/$1/domains.txt > $ROOT/$1/domains-http.txt # puts the http protocol in front of the list with domains - thanks @EdOverflow :)
	#sed 's#^#https://#g' $ROOT/$1/domains.txt > $ROOT/$1/domains-https.txt
  #cat "$RESULTDIR"/amass-domains.txt | online >> "$RESULTDIR"/amass-online.txt
  # TODO CHECKEN

  # while IFS='' read -r line || [[ -n "$line" ]]; do
	#   if ping -c 1 "$(echo "$line" | tr -d '[:space:]')" &> /dev/null
	#   then
	# 	  IP=$(getent hosts "$domain" | cut -d' ' -f1 | head -n 1)
	# 	  echo "$(echo "$line" | tr -d '[:space:]'),$IP"
	#   fi
  # done < "$RESULTDIR"/amass-domains.txt > "$RESULTDIR"/amass-online.txt
  echo "COMBINE & SORT AMASS"
  cat "$RESULTDIR"/amass.txt >> "$RESULTDIR"/subdomains.txt # voor nu raw amass results
  sort -u "$RESULTDIR/subdomains.txt" -o "$RESULTDIR/subdomains.txt"
}

: 'run altdns'
runAltdns()
{
  # check , geeft foutmelding
  echo -e "[$GREEN+$RESET] ALTDNS"
  altdns -i "$RESULTDIR/subdomains.txt"  -o "$RESULTDIR/altdns-wordlist.txt" -w "$HOME"/tools/altdns/words.txt
  echo -e "[$GREEN+$RESET] COMBINE & SORT ALTDNS"
  #cat "$RESULTDIR"/altdns-wordlist.txt >> "$RESULTDIR"/subdomains.txt
  sort -u "$RESULTDIR/subdomains.txt" -o "$RESULTDIR/subdomains.txt"
}

: 'check wildcards'
checkWildcards()
{
  echo -e "[$GREEN+$RESET] Checking for wildcards"
  if [[ "$(dig @1.1.1.1 A,CNAME {test321123,testingforwildcard,plsdontgimmearesult}."$domain" +short | wc -l)" -gt "1" ]]; then
      echo "[!] Possible wildcard detected."
      else
        echo -e "[$GREEN+$RESET] No wildcards found."
  fi
}

: 'Run GetJS on scanresults and store output in file'
runMeg()
{
	echo -e "[$GREEN+$RESET] Running $GREEN meg$RESET on scan results.."
	#sed 's#^#http://#g' "$RESULTDIR"/domains.txt > "$RESULTDIR"/domains-http.txt # puts the http protocol in front of the list with domains - thanks @EdOverflow :)
	#sed 's#^#https://#g' "$RESULTDIR"/domains.txt > "$RESULTDIR"/domains-https.txt
	#cat "$RESULTDIR"/subdomains.txt | "$HOME"/go/bin/getJS | "$HOME"/go/bin/tojson >> "$RESULTDIR"/$domain-JS-files.txt
	
  echo -e "[$GREEN+$RESET] Done, output has been saved to: $domain-JS-files.txt"
}

: 'portscan massdns'
portMasscan()
{
  echo -e "[$GREEN+$RESET] Starting masscan portscan"
  "$HOME"/tools/masscan/bin/masscan "$(dig +short "$domain" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)" -p0-10000 --rate 1000 --wait 3 2> /dev/null | grep -o -P '(?<=port ).*(?=/)' >> $RESULTDIR/$domain-ports.txt

  echo -e "[$GREEN+$RESET] Starting nmap scan"
  nmap -p "$(cat "$RESULTDIR"/"$domain"-ports.txt | paste -sd "," -) $(dig +short "$domain" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -1)"
}

: 'sublert'
sublertScan()
{
  echo -e "[$GREEN+$RESET] Adding $domain to sublert."
  python3 "$HOME"/tools/sublert/sublert.py -u "$domain";
  cp "$HOME"/sublert/output/"$domain".txt "RESULTDIR"/sublert-output.txt;
  
}



: 'check online'
checkOnline()
{
  echo -e "[$GREEN+$RESET] Check online targets"
  #printf "https://poc-server.com\nhttps://example.com\nhttps://notexisting003.com\nhttp://google.com" | online
  # use cat subdomains.txt | online?

  for port in `sed '/^$/d' "$RESULTDIR/$domain-ports.txt"`; do
    url="$domain:$port"
    http=false
    https=false
    protocol=""

    if [[ $(echo "http://$url" | "$HOME"/go/bin/online) ]]; then http=true; else http=false; fi
    if [[ $(echo "https://$url" | "$HOME"/go/bin/online) ]]; then https=true; else https=false; fi

    if [[ "$http" = true ]]; then protocol="http"; fi
    if [[ "$https" = true ]]; then protocol="https"; fi

    if [[ "$http" = true && "$https" = true ]]; then
      # If the content length of http is greater than the content length of https, then we choose http, otherwise we go with https
      contentLengthHTTP=$(curl -s http://$url | wc -c)
      contentLengthHTTPS=$(curl -s https://$url | wc -c)
      if [[ "$contentLengthHTTP" -gt "$contentLengthHTTPS" ]]; then protocol="http"; else protocol="https"; fi

      if [[ "$port" == "80" ]]; then protocol="http"; fi
      if [[ "$port" == "443" ]]; then protocol="https"; fi
    fi

    if [[ ! -z "$protocol" ]]; then
      echo "$protocol://$domain:$port"
    fi
  done >> $RESULTDIR/$domain-urls.txt

  echo -e "[$GREEN+$RESET] URLs found:" $(cat $RESULTDIR/$domain-urls.txt | wc -l)
}

: 'sort results from bruteforce'
sortBruteResults()
{
  echo -e "[$GREEN+$RESET] Sorting last results.."
  touch "$RESULTDIR"/subs-filtered.txt
  cat "$RESULTDIR"/amass.txt "$RESULTDIR"/subfinder-online.txt >> "$RESULTDIR"/subs-filtered.txt
  sort -u "$RESULTDIR/subs-filtered.txt" -o "$RESULTDIR/subs-filtered.txt"
  echo -e "[$GREEN+$RESET] Done"
}

: 'results overview'
resultsOverview()
{
  echo -e "Finished"
  echo -e "[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]"
  echo -e $(cat "$RESULTDIR"/bruteforce-online.txt | wc -l) "- bruteforce"
  echo -e $(cat "$RESULTDIR"/amass.txt | wc -l) "- amass"
  echo -e $(cat "$RESULTDIR"/subfinder-online.txt | wc -l) "- subfinder"
  echo -e $(cat "$RESULTDIR"/assetfinder-online.txt | wc -l) "- assetfinder"
  echo -e $(cat "$RESULTDIR"/altdns-wordlist.txt | wc -l) "- altdns"
  echo -e $(cat "$RESULTDIR"/sublert-output.txt | wc -l) "- sublert"
  echo -e $(cat "$RESULTDIR"/subdomains.txt | wc -l) "- total"
  echo -e $(cat "$RESULTDIR"/subs-filtered.txt | wc -l) "- filtered/online"
  echo -e "[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]-[$GREEN+$RESET]"
}
### CHECKEN
: 'Convert domains.txt to json (subdomainDB format)'
convertDomainsFile()
{
	echo -e "[$GREEN+$RESET] Converting $GREEN"$RESULTDIR"/subdomains.txt$RESET to an acceptable $GREEN.json$RESET file.."
	cat "$RESULTDIR"/subdomains.txt | grep -P "([A-Za-z0-9]).*$domain" >> "$RESULTDIR"/domains-striped.txt
	( echo -e "{\\n\"domains\":"; jq -MRs 'split("\n")' < "$RESULTDIR"/domains-striped.txt | sed -z 's/,\n  ""//g'; echo -e "}" ) &> "$RESULTDIR"/domains.json
}

: 'Start up the dashboard server'
startDashboard()
{
	echo -e "[$GREEN+$RESET] Starting dashboard and adding results for $GREEN$domain$RESET:"
	# make some sort of check to see if the docker is already running and if so, don't run the docker command.
	docker run -d -v subdomainDB:/subdomainDB -p 0.0.0.0:4000:4000 subdomaindb
	sleep 10 # Required for the first run only, otherwise the POST request will be rejected.
	curl -X POST \
  	http://0.0.0.0:4000//api/domain/%20$domain \
  	-H 'cache-control: no-cache' \
  	-H 'content-type: application/json' \
  	-d @"$RESULTDIR"/domains.json # fix (done?)
	echo -e "[$GREEN+$RESET] $domain scan results available on http://recon.pi.ip.address:4000"	
}

: 'Check all bugbounty targets'
checkAll()
{
  #check && todo
  echo -e "Would you like to check all bug bounty targets?"
  # To view the wildcard domains simply run:
  cat ./bounty-targets-data/data/wildcards.txt
}

: 'Enumarate subdomains from all the wildcard targets'
enumerateAll()
{ 
  # needs testing n shit
  cd "$BASERESULT"/subdomain_takeover/bounty-targets-data/ || return; 
  git pull; 
  cd "$RESULTDIR" || return; 
  cp "$BASERESULT"/subdomain_takeover/bounty-targets-data/data/wildcards.txt ./; cat wildcards.txt | sed 's/^*.//g' | grep -v '*' > wildcards_without_stars.txt; 
  while read host;  # -r ?
    do file=$host && file+="_subfinder.out"; 
    "$HOME"/go/bin/subfinder -o $file -d "$host"; 
  done < ./wildcards_without_stars.txt
  at ./*.out > all_subdomains.lst; 
  SubOver -l ./all_subdomains.lst -timeout 5 -o subover.out;
  echo -e "[$GREEN+$RESET] Done."
}

## TODO
### - fix juiste werkflow
### - replace "online" with "httprobe"
### - implement assetfinder
### - implement meg
### - implement gf, gron etc (optional)
### - replace current functions with new above tooling
### - implement webscreenshot.py?
### - improve directory structure: main domain.tld -> subs.domain.tld (all own dir)

: 'Clean up'
cleanup()
{
	# TODO: Check if there are more useless files
	echo -e "[$GREEN+$RESET] Would you like to set a cronjob for $domain?"
	#rm "$RESULTDIR"/*-*.txt # remove unnecessary files
	#rm $ROOT/$1/domains-striped.txt
	sleep 1
	echo -e "[$GREEN+$RESET] Done, ready for the next scan!"
}

: 'Execute the main functions'
displayLogo
checkArguments    		
checkDirectory    
checkDirectory2
bruteForce			
runSubfinder
runAssetfinder
sortBruteResults
# assetfinder?
#runAmass
runAltdns
# 
checkWildcards
#runGetJS # 
portMasscan # fix nmap
#checkOnline # httprobe?
#sortBruteResults # meer naar boven?
resultsOverview
convertDomainsFile
startDashboard
#checkAll
#enumerateAll
sublertScan
cleanup				