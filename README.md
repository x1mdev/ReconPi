# Recon Pi

```
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                            v2.0 - by @x1m_martijn
```

<p align="center"><a href="https://twitter.com/x1m_martijn" target="_blank"><img src="https://img.shields.io/twitter/follow/x1m_martijn.svg?logo=twitter"></a></p>

ReconPi - A lightweight recon tool that performs extensive reconnaissance with the latest tools using a Raspberry Pi.

Start using that Raspberry Pi -- I know you all have one laying around somewhere ;)

## Installation

Check the updated blogpost here for a complete guide on how to set up your own ReconPi: [ReconPi Guide](https://x1m.nl/posts/recon-pi/) 


If you prepared your Raspberry Pi through the guide linked above you should be able to continue below.

> ReconPi v2.0 needs the [HypriotOS](https://blog.hypriot.com/downloads/) (V1.10.0) image to work 100%!

### Easy installation

Connect to your ReconPi with SSH:

`ssh pirate@192.168.2.16 [Change IP to ReconPi IP]`

Curl the `install.sh` script and run it:

`curl -L https://raw.githubusercontent.com/x1mdev/ReconPi/master/install.sh | bash`

### Manual installation

Connect to your ReconPi with SSH:


`$ ssh pirate@192.168.2.16 [Change IP to ReconPi IP]`

Now we can set up everything, it's quite simple:

 - `git clone https://github.com/x1mdev/ReconPi.git`
 - `cd ReconPi`
 - `./install.sh`
 - The script gives a `reboot` command at the end of `install.sh`, please login again to start using the ReconPi.

Grab a cup of coffee since this will take a while.

## Usage

After installing all of the dependencies for the ReconPi you can finally start doing some recon!

```
$ recon <domain.tld>
```

`recon.sh` will first gather resolvers for the given target, followed by subdomain enumeration and checking those assets for potential subdomain takeover. When this is done the IP addresses of the target are enumerated. Open ports will be discovered accompanied by a service scan provided by Nmap.

Finally the live targets will be screenshotted and evaluated to discover endpoints.

Results will be stored on the Recon Pi and can be viewed by running `python -m SimpleHTTPServer 1337" in your results directory. Your results will be accessible from any system with a browser that exists in the same network. 


## Tools

Tools that are being used at this moment:

 - [HypriotOS](https://blog.hypriot.com/downloads/)
 - [GO](https://github.com/golang)
 - [Subfinder](https://github.com/Ice3man543/subfinder) (now running on native Go)
 - [aquatone](https://github.com/michenriksen/aquatone)
 - [httprobe](https://github.com/tomnomnom/httprobe)
 - [assetfinder](https://github.com/tomnomnom/assetfinder)
 - [meg](https://github.com/tomnomnom/meg)
 - [gobuster](https://github.com/OJ/gobuster)
 - [Amass](https://github.com/OWASP/Amass)
 - [MassDNS](https://github.com/blechschmidt/massdns)
 - [masscan](https://github.com/robertdavidgraham/masscan)
 - [nmap](https://nmap.org/)
 - [CORScanner](https://github.com/chenjj/CORScanner)
 - [sublert](https://github.com/yassineaboukir/sublert)
 - [bass](https://github.com/Abss0x7tbh/bass)
 - [LinkFinder](https://github.com/GerbenJavado/LinkFinder)

More tools will be added in the future, feel free to make a pull request!

## Contributors

  - [Damian Ebelties](https://github.com/ebelties)

## Support

If you like what I do, feel free to: <a href="https://www.buymeacoffee.com/x1m"><img src="https://cdn-images-1.medium.com/max/738/1*G95uyokAH4JC5Ppvx4LmoQ@2x.png" width="150"></a>