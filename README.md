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

Check the blogpost here for a complete guide on how to set up your own ReconPi: [ReconPi Guide](https://x1m.nl/posts/recon-pi/) 

> The guide will be updated soon!

If you prepared your Raspberry Pi through the guide linked above you should be able to continue below.

Connect to your ReconPi with SSH:

```
$ ssh pi@192.168.2.39 [Change IP to ReconPi IP]
```

When you connect to the ReconPi for the first time you will be asked to change the default password (`raspberry`). After the password change you will have to log in again with the new password.

Now we can set up everything, it's quite simple:

 - `wget https://raw.githubusercontent.com/x1mdev/ReconPi/master/install.sh`
 - `sudo bash ReconPi/install.sh`
 - The script gives a `reboot` command at the end of `install.sh`, please login again to start using the ReconPi.

Grab a cup of coffee since this will take a while.

## Usage

After installing all of the dependencies for the ReconPi we can finally start doing some recon!

```
$ sudo bash ReconPi/recon.sh <domain.tld>
```

`recon.sh` creates a directory named equal to the `domain.tld` provided within it's initial directory `$HOME/bugbounty`. It then starts the recon process.

Tools that are being used at this moment:

 - [Raspbian Stretch Lite image](https://www.raspberrypi.org/downloads/raspbian/)
 - [GO](https://github.com/golang)
 - [Echo](https://github.com/labstack/echo)
 - [Subfinder](https://github.com/Ice3man543/subfinder) (now running on native Go)
 - [MassDNS](https://github.com/blechschmidt/massdns)

More tools will be added in the future, feel free to make a Pull Request!

Current output is in simple `.txt` and `.json` files. I have developed a little web application that runs on a minimal Go server, which will be installed during the `install.sh` process.

It doesn't have any input yet, but the dashboard is accessible within the local network. You can visit it by navigating to `https://192.168.2.PI-IP:1337`

## Contributors

 - [Damian Ebelties](https://github.com/ebelties)

If you like this project you can get me a cup of coffee :) [ko-fi.com/martijn](http://ko-fi.com/martijn)

## v1.0.0 Changelog

 - Fixed massdns issue; the `cp` command in `install.sh` did not work due to "
 - Fixed write issue to domains.json
 - Implemented [subdomainDB](https://github.com/smiegles/subdomainDB)
 - Switched base OS: [Hypriot OS](https://blog.hypriot.com/downloads/), Docker ships by default.
 - Made a few changes to `install.sh` to get all the requirements needed for `recon.sh`