todo fix

``` python

[+] COMBINE & SORT SUBFINDER
[+] AMASS
Crtsh: Failed to connect to the database server: dial tcp 91.199.212.48:5432: connect: connection refused
[+] CHECK AMASS
COMBINE & SORT AMASS
[+] ALTDNS
python: can't open file '/root/tools/altdns/altdns.py': [Errno 2] No such file or directory
[+] COMBINE & SORT ALTDNS
cat: /root/bugbounty/x1m.nl/altdns-wordlist.txt: No such file or directory
[+] Checking for wildcards
[+] No wildcards found.
[+] Running  GetJS on scan results..
sed: can't read //domains.txt: No such file or directory
sed: can't read //domains.txt: No such file or directory
cat: //all-subdomains.txt: No such file or directory
[+] Done, output has been saved to: -JS-files.txt
[+] Starting masscan portscan
[+] Starting nmap scan
Starting Nmap 7.70 ( https://nmap.org ) at 2019-04-30 14:08 UTC
Error #487: Your port specifications are illegal.  Example of proper form: "-100,200-1024,T:3000-4000,U:60000-"
QUITTING!
[+] Check online targets
[+] URLs found: 0
[+] Sorting last results..
[+] Done
Finished
[+]-[+]-[+]-[+]-[+]-[+]-[+]-[+]-[+]-[+]
6 - bruteforce
0 - amass
2 - subfinder
cat: /root/bugbounty/x1m.nl/altdns-wordlist.txt: No such file or directory
0 - altdns
8 - total
2 - filtered/online
[+]-[+]-[+]-[+]-[+]-[+]-[+]-[+]-[+]-[+]
[+] Converting //domains.txt to an acceptable .json file..
cat: //domains.txt: No such file or directory
[+] Starting dashboard and adding results for :
64cfce594cf6e4074c0fd7f4730885c17b65a3415dfd7aef8a745546ccfbd9d2
{
  "message": "domain(s) inserted",
  "success": true
}[+]  scan results available on http://recon.pi.ip.address:4000
[+] Cleaning up..
rm: cannot remove '//.txt': No such file or directory
[+] Done, ready for the next scan!

```

## TODO

- add directory bruteforce / content discovery (gobuster/dirsearch)
- fix cronjobs
