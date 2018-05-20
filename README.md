# Recon Pi

ReconPi - A lightweight recon tool that performs extensive domain scanning with the latest tools using a Raspberry Pi and Docker.

Start using that Raspberry Pi, I know you all have one laying around somewhere ;)

This project is in development, PR's are welcome!

## Installation

Check the blogpost here for a complete guide: link

Connect to your ReconPi with SSH (default creds):

``` bash

ssh ubuntu@192.168.2.56

```

Password: `ubuntu`


There are 2 options:

**Option 1:**

 - `git clone https://github.com/x1mdev/ReconPi.git`
 - `cd ReconPi`
 - `chmod +x install.sh`
 - `sudo bash install.sh`

**Option 2:**

Download the `install.sh` script:

``` bash

wget public link

```

Give it the right permission:

``` bash

chmod +x install.sh

```

Run the install script:

``` bash

# Don't forget sudo!
sudo bash install.sh

```

Grab a cup of coffee, this will take a few minutes.

## Usage

Usage:

``` bash

bash recon.sh domain.tld`

```

`recon.sh` creates a directory named equal to the domain.tld provided within it's initial directory "bugbounty". It then starts the recon process.

Tools that are being used at this moment:

 - [Subfinder](https://github.com/Ice3man543/subfinder)
 - [amass](https://github.com/caffix/amass)
 - [massdns](https://github.com/blechschmidt/massdns)

More tools will be added in the future, feel free to make a PR!

Current output is in simple `.txt` files. The plan is to develop a little dashboard that will launch as soon as `recon.sh` is done. Docker can probably make this happen :)