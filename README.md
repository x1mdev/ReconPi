# Recon Pi

```
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                          v0.2.0 - by @x1m_martijn
```

ReconPi - A lightweight recon tool that performs extensive domain scanning with the latest tools using a Raspberry Pi and GO.

Start using that Raspberry Pi -- I know you all have one laying around somewhere ;^)

This project is in development. Pull Requests are welcome!

## Installation

Check the blogpost here for a complete guide: [ReconPi Guide](https://x1m.nl/posts/recon-pi/) 

> Needs to be updated due to changes!

Connect to your ReconPi with SSH (default credentials):

```
$ ssh pi@192.168.2.56
```

When you connect to the ReconPi for the first time you will be asked to change the default password (`pi`). After the password change you will have to log in again with the new password.

Now we can set up everything, it's quite simple:

(maybe do a wget to first script because stretch lite does not have git by default)

 - `git clone https://github.com/x1mdev/ReconPi.git`
 - `sudo bash ReconPi/initial_install.sh`
 - The script gives a `logout` command at the end of `install.sh`, please login again to continue with `install2.sh`.
 - `sudo bash ReconPi/second_install.sh`

The `install.sh` script now consists of 2 parts, I'll try and think of a solution to combine it back in to one script.


It's under development.

Grab a cup of coffee since this will take a while.

## Usage

```
$ sudo bash ReconPi/recon.sh <domain.tld>
```

`recon.sh` creates a directory named equal to the `domain.tld` provided within it's initial directory `$HOME/bugbounty`. It then starts the recon process.

Tools that are being used at this moment:

 - [Subfinder](https://github.com/Ice3man543/subfinder) (now running on native Go)
 - [Amass](https://github.com/caffix/amass)
 - [MassDNS](https://github.com/blechschmidt/massdns)
 - [subdomainDB](https://github.com/smiegles/subdomainDB)
 - [Aquatone](https://github.com/michenriksen/aquatone)

More tools will be added in the future, feel free to make a Pull Request!

Current output is in simple `.txt` files. I have added [subdomainDB](https://github.com/smiegles/subdomainDB) to the arsenal and it will be installed during the `install.sh` process.

It doesn't have any input yet, but the dashboard is accessible within the local network. You can visit it by navigating to `https://192.168.2.PI-IP`

## Contributors

 - [Damian Ebelties](https://github.com/ebelties) 
