# Recon Pi

```
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                          v1.0.0 - by @x1m_martijn
```

ReconPi - A lightweight recon tool that performs extensive domain scanning with the latest tools using a Raspberry Pi and GO. After the installation the ReconPi only needs a WiFi connection and some power, easy does it.

Start using that Raspberry Pi -- I know you all have one laying around somewhere ;)

This project is in development. Pull requests are welcome!

## Installation

Check the updated blogpost here for a complete guide on how to set up your own ReconPi: [ReconPi Guide](https://x1m.nl/posts/recon-pi/) 


If you prepared your Raspberry Pi through the guide linked above you should be able to continue below.

Connect to your ReconPi with SSH:

```
$ ssh pirate@192.168.2.16 [Change IP to ReconPi IP]
```

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

`recon.sh` creates a directory named equal to the `domain.tld` provided within it's initial directory `$HOME/bugbounty`. It then starts the recon process.

Tools that are being used at this moment:

 - [Hypriot OS](https://blog.hypriot.com/downloads/)
 - [GO](https://github.com/golang)
 - [Docker](https://www.docker.com/)
 - [subdomainDB](https://github.com/smiegles/subdomainDB)
 - [Subfinder](https://github.com/Ice3man543/subfinder) (now running on native Go)
 - [MassDNS](https://github.com/blechschmidt/massdns)

More tools will be added in the future, feel free to make a Pull Request!

Output is written to http://192.168.2.16:4000 (replace with your own ReconPi address).

## Contributors

 - [Damian Ebelties](https://github.com/ebelties)

## v1.0.0 Changelog

 - Fixed massdns issue; the `cp` command in `install.sh` did not work due to "
 - Fixed write issue to domains.json
 - Implemented [subdomainDB](https://github.com/smiegles/subdomainDB)
 - Switched base OS: [Hypriot OS](https://blog.hypriot.com/downloads/), Docker ships by default.
 - Made a few changes to `install.sh` to get all the requirements needed for `recon.sh`
 - Finished the curl POST request call to show data on the dashboard.
 - Tested the `install.sh` and `recon.sh` scripts on a freshly installed RPi + Hypriot OS.