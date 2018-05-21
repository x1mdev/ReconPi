# Recon Pi

```
__________                          __________.__ 
\______   \ ____   ____  ____   ____\______   \__|
 |       _// __ \_/ ___\/  _ \ /    \|     ___/  |
 |    |   \  ___/\  \__(  <_> )   |  \    |   |  |
 |____|_  /\___  >\___  >____/|___|  /____|   |__|
        \/     \/     \/           \/             
                          v0.1.1 - by @x1m_martijn
```

ReconPi - A lightweight recon tool that performs extensive domain scanning with the latest tools using a Raspberry Pi and Docker.

Start using that Raspberry Pi -- I know you all have one laying around somewhere ;^)

This project is in development. Pull Requests are welcome!

## Installation

Check the blogpost here for a complete guide: [ReconPi Guide](https://x1m.nl/posts/recon-pi/)

Connect to your ReconPi with SSH (default credentials):

```
$ ssh ubuntu@192.168.2.56
```

Password: `ubuntu`

There are 2 options:

**Option 1:**

 - `git clone https://github.com/x1mdev/ReconPi.git`
 - `cd ReconPi`
 - `sudo bash install.sh`

**Option 2:**

Download the `install.sh` script:

```
$ wget https://raw.githubusercontent.com/x1mdev/ReconPi/master/install.sh
```

Give it the right permission:

```
$ chmod +x install.sh
```

Run the install script:

```
# Don't forget sudo!
$ sudo bash install.sh
```

Grab a cup of coffee since this will take a few minutes.

## Usage

Usage:

```
$ bash recon.sh <domain.tld>
```

`recon.sh` creates a directory named equal to the `domain.tld` provided within it's initial directory `$HOME/bugbounty`. It then starts the recon process.

Tools that are being used at this moment:

 - [Subfinder](https://github.com/Ice3man543/subfinder)
 - [Amass](https://github.com/caffix/amass)
 - [MassDNS](https://github.com/blechschmidt/massdns)

More tools will be added in the future, feel free to make a Pull Request!

Current output is in simple `.txt` files. The plan is to develop a little dashboard that will launch as soon as `recon.sh` is done. Docker can probably make this happen :)

## Contributors

 - [Damian Ebelties](https://github.com/ebelties) 