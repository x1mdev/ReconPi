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

ReconPi - A lightweight recon tool that performs extensive reconnaissance with the latest tools using a Raspberry Pi.

Start using that Raspberry Pi -- I know you all have one laying around somewhere ;)

## Installation

Check the updated blogpost here for a complete guide on how to set up your own ReconPi: [ReconPi Guide](https://x1m.nl/posts/recon-pi/) 


If you prepared your Raspberry Pi through the guide linked above you should be able to continue below.

> ReconPi v2.0 needs the [HypriotOS](https://blog.hypriot.com/downloads/) image to work 100%!

### Manual installation

Connect to your ReconPi with SSH:

```
$ ssh root@192.168.2.16 [Change IP to ReconPi IP]
```

Now we can set up everything, it's quite simple:

 - `git clone https://github.com/x1mdev/ReconPi.git`
 - `cd ReconPi`
 - `./install.sh`
 - The script gives a `reboot` command at the end of `install.sh`, please login again to start using the ReconPi.

### Easy mode

`wget https://raw.githubusercontent.com/x1mdev/ReconPi/dev/v2.0/install.sh | bash

Grab a cup of coffee since this will take a while.

## Usage

After installing all of the dependencies for the ReconPi you can finally start doing some recon!

```
$ recon <domain.tld>
```

`recon.sh` creates a directory named equal to the `domain.tld` provided within it's initial directory `$HOME/bugbounty`. It then starts the recon process.

Tools that are being used at this moment:

 - [Hypriot OS](https://blog.hypriot.com/downloads/)
 - [GO](https://github.com/golang)
 - [Subfinder](https://github.com/Ice3man543/subfinder) (now running on native Go)
 - [aquatone](https://github.com/michenriksen/aquatone)
 - [httprobe](https://github.com/tomnomnom/httprobe)
 - [assetfinder](https://github.com/tomnomnom/assetfinder)
 - [meg](https://github.com/tomnomnom/meg)
 - [tojson](https://github.com/tomnomnom/hacks/tojson)
 - [gobuster](https://github.com/OJ/gobuster)
 - [Amass](https://github.com/OWASP/Amass)
 - [MassDNS](https://github.com/blechschmidt/massdns)
 - [masscan](https://github.com/robertdavidgraham/masscan)
 - [CORScanner](https://github.com/chenjj/CORScanner)
 - [sublert](https://github.com/yassineaboukir/sublert)
 - [LinkFinder](https://github.com/GerbenJavado/LinkFinder)

More tools will be added in the future, feel free to make a pull request!

Results will be hosted at http://0.0.0.0, which is reachable from the local Raspberry Pi IP address.

## Contributors

 - [Damian Ebelties](https://github.com/ebelties)

## Coming soon

 - More detailed scan results on the dashboard.
 - Add more tools.

## v1.1.0 Changelog

- Added some more tools: 
 [GetJS](https://github.com/003random/getJS) &
 [tojson](https://github.com/tomnomnom/hacks/tojson)
- 
## v1.0.2 Changelog

 - Fixed massdns issue; the `cp` command in `install.sh` did not work due to "
 - Fixed write issue to domains.json
 - Implemented [subdomainDB](https://github.com/smiegles/subdomainDB)
 - Switched base OS: [Hypriot OS](https://blog.hypriot.com/downloads/), Docker ships by default.
 - Made a few changes to `install.sh` to get all the requirements needed for `recon.sh`
 - Finished the curl POST request call to show data on the dashboard.
 - Tested the `install.sh` and `recon.sh` scripts on a freshly installed RPi + Hypriot OS.
 - Added cleanup function
 - Moved all of the loose parts in to functions in `install.sh`

 ## v2.0 Changelog

  - `install.sh` is now more efficient.
  - `recon.sh` has been extended
  - More tools have been added