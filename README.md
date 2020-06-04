# Recon Pi

```
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                            v2.0
```

Original Author: @x1m/_martijn

ReconPi - A lightweight recon tool that performs extensive reconnaissance with the latest tools using a Raspberry Pi.

Start using that Raspberry Pi -- I know you all have one laying around somewhere ;)


I added lot of tools on top of the original so I think it is diverted to its only use of running it on RaspberryPi.

I use this tool extensively on my cloud server so spin up your own cloud server and recon everything.

Added wordlists from tomnomnom common files, few raft lists and all.txt(jhaddix)

### Easy installation

Connect to your ReconPi with SSH:

`ssh pirate@192.168.2.16 [Change IP to ReconPi IP]` or ssh to your cloud server

Curl the `install.sh` script and run it:
`curl -L https://raw.githubusercontent.com/x1mdev/ReconPi/master/install.sh | bash`

### Manual installation

Connect to your ReconPi with SSH:


`$ ssh pirate@192.168.2.16 [Change IP to ReconPi IP]`

Now we can set up everything, it's quite simple:

 - `git clone https://github.com/x1mdev/ReconPi.git`
 - `cd ReconPi`
 - `./install.sh`

Grab a cup of coffee since this will take a while.

## Usage

After installing all of the dependencies for the ReconPi you can finally start doing some recon!

```
$ recon <domain.tld>
```

`recon.sh` will first gather resolvers for the given target, followed by subdomain enumeration and checking those assets for potential subdomain takeover. When this is done the IP addresses of the target are enumerated. Open ports will be discovered accompanied by a service scan provided by Nmap.

Finally the live targets will be screenshotted and evaluated to discover endpoints.

Results will be stored on the Recon Pi and can be viewed by running `python -m SimpleHTTPServer 1337" in your results directory. Your results will be accessible from any system with a browser that exists in the same network. 

Make sure to add your SLACK token to the tokens.txt file if you want to get slack notification after the completion of recon process.

## Sample Token.txt

github\_subdomains\_token=""
slack\_url=""
findomain\_spyse\_token=""
findomain\_virustotal\_token=""
findomain\_securitytrails\_token=""

## Tools

Tools that will be installed:
- [Go](https://github.com/golang)
- [Subfinder](https://github.com/projectdiscovery/subfinder/cmd/subfinder)
- [Subjack](htttps://github.com/haccer/subjack)
- [Aquatone](https://github.com/michenriksen/aquatone)
- [httprobe](https://github.com/tomnomnom/httprobe)
- [assetfinder](https://github.com/tomnomnom/assetfinder)
- [meg](https://github.com/tomnomnom/meg)
- [tojson](https://github.com/tomnomnom/hacks/tojson)
- [unfurl](https://github.com/tomnomnom/unfurl)
- [gf](https://github.com/tomnomnom/gf)
- [anew](https://github.com/tomnomnom/anew)
- [qsreplace](https://github.com/tomnomnom/qsreplace)
- [ffuf](https://github.com/ffuf/ffuf)
- [gobuster](https://github.com/OJ/gobuster)
- [amass](https://github.com/OWASP/Amass)
- [getJS](https://github.com/003random/getJS)
- [gau](https://github.com/lc/gau)
- [shuffledns](https://github.com/projectdiscovery/shuffledns/cmd/shuffledns)
- [dnsprobe](https://github.com/projectdiscovery/dnsprobe)
- [naabu](https://github.com/projectdiscovery/naabu/cmd/naabu)
- [nuclei](https://github.com/projectdiscovery/nuclei/cmd/nuclei)
- [nuclei-template](https://github.com/projectdiscovery/nuclei-templates)
- [cf-check](https://github.com/dwisiswant0/cf-check)
- [massdns](https://github.com/blechschmidt/massdns)
- [jq](https://stedolan.github.io/jq/)
- [masscan](https://github.com/robertdavidgraham/masscan)
- [Corsy](https://github.com/s0md3v/Corsy)
- [dirsearch](https://github.com/maurosoria/dirsearch)
- [XSStrike](https://github.com/s0md3v/XSStrike)
- [Arjun](https://github.com/s0md3v/Arjun)
- [Diggy](https://github.com/s0md3v/Diggy)
- [Dnsgen](https://github.com/ProjectAnte/dnsgen)
- [Sublert](https://github.com/yassineaboukir/sublert)
- [Findomain](https://github.com/Edu4rdSHL/findomain)
- [github-subdomain](https://raw.githubusercontent.com/gwen001/github-search/master/github-subdomains.py)
- [linkfinder](https://github.com/GerbenJavado/LinkFinder)
- [bass](https://github.com/Abss0x7tbh/bass)
- [interlace](https://github.com/codingo/Interlace)
- [nmap](https://nmap.org)
- [Seclist](https://github.com/danielmiessler/SecList)

## Methodology
- gatherResolvers
- gatherSubdomains
- checkTakeovers
- getCNAME
- gatherIPs
- gatherScreenshots
- startMeg
- fetchArchive
- fetchEndpoints
- runNuclei
- portScan
- notifySlack

**Subdomain Enumeration:**
- Sublert
- Subfinder
- assetfinder
- amass passive and active enum
- findomain (Add findomain sources token to get better result)
- github-subdomains
- dns.bufferover.run
- Mutate above Subdomains using commonspeak subdomain list

- Combine and Sort above result -> Use shuffledns to resolve -> dnsgen(to mutate) -> httprobe (to get alive hosts)

- Check takeover using subjack and nuclei

- Get CNAME to check manually for takeovers

- Use dnsprobe to gather IP, ignore if they fall in cloudflare ip range

- Do masscan and then nmap scan on them, also use http-title and vulners script.

- Take Screenshot for visual recon

- Use gau to to get archive urls, get paramlist, jsurls, phpurls, aspxurls, and jspurls in there own files.

- Get Endpoints using Linkfinder

- Run Nuclei Scripts on alive hosts

- Notify on Slack channel if token is specified.

- Directory Buteforcing (Not enabled, as it takes long time, it is better to do manually)

More tools will be added in the future, feel free to make a pull request!

## Contributors

  - [Sachin Grover](https://github.com/mavericknerd) (Twitter: @mavericknerd)
  - [Damian Ebelties](https://github.com/ebelties)
