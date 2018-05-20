# Recon Pi

ReconPi - Lightweight Recon tool that performs extensive scanning with the latest tools using a Raspberry Pi and Docker.


You can also write output in JSON format as used by Aquatone.

`./subfinder -d freelancer.com -o result_aquatone.json -oA -nW -v `

You can specify custom resolvers too.

`./subfinder -d freelancer.com -o result_aquatone.json -oA -nW -v -r 8.8.8.8,1.1.1.1`
`./subfinder -d freelancer.com -o result_aquatone.json -oA -nW -v -rL resolvers.txt`

## NIEUWE SUBFINDER COMMAND:

x1m@RPi3:~/subfinder$ docker run -v $HOME/.config/subfinder:/root/.config/subfinder -it subfinder -d yahoo.net > yahoo.net.txt


## Grep domains uit die txt want extra meuk

``` bash

if [ -e domainsfile.txt ];then
	echo 'Sublist3r Scan complete, checking which domains resolve..'
	while read domain; 
	do if host "$domain" > /dev/null; 
	then echo $domain; 
	fi; 
	done < domainsfile.txt >> resolveddomains.txt
	echo 'Resolved domains written to resolveddomains.txt'
	sleep 1

```
Hoeft niet via grep want --no-pager

Script is working in progress
