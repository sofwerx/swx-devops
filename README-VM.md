# Using the Environment
#### One-time setup:
- Copy your ```secring.gpg``` to ```~/.gnupg```
- Export your public key to a file with your email address as the filename:
```gpg --export --armor > youremailaddress```
- Within SWX: send your public key to one of the Nerd Herd
- Public keys are stored in the gpg/ folder in the swx-devops GitHub repo,
and each server's gpg/ folder is populated from there.

#### At a shell window or terminal/ssh command line:

```bash
export TROUSSEAU_PASSPHRASE='<your gpg passphrase here>'
cd swx-devops
git pull
. ./shell.bash
```
(The '.' above is critical, you need the shell.bash contents to take effect
in your running login shell. Running shell.bash as a script creates a new subshell,
and the environment settings will go away when the shell script exits.)

# Installation
(The steps below have already been done on the VirtualBox image distributed within SWX)

As installed on linux VirtualBox (Debian 10 - 4.19 kernel w/ Guest Additions installed)

```apt-get install``` the following packages:
-	build-essentials
-	kernel-headers
-	dkms
-	module-assistant
```bash
m-a prepare
apt update
apt upgrade
```
Install Guest Additions - mount cdrom from VirtualBox menu

Run ```sudo bash /media/cdrom/VBoxLinuxAdditions.run```

Below may also be needed:
```bash
	cd /opt/VBoxGuestAdditions-<version>/init
	./vboxadd stop
	./vboxadd setup
```
Add vboxguest & vboxsf to /etc/modules

Create shared folder in VirtualBox settings, mkdir mount point, add to fstab, mount

## Docker

### Docker Engine
Follow appropriate platform install instructions from docker.com:
https://docs.docker.com/install/linux/docker-ce/debian/

OR

```bash
sudo apt-get curl
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker your-user
```

### Docker Machine
https://docs.docker.com/machine/install-machine/#installing-machine-directly

```bash
base=https://github.com/docker/machine/releases/download/v0.16.0 &&
  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
  sudo mv /tmp/docker-machine /usr/local/bin/docker-machine &&
  chmod +x /usr/local/bin/docker-machine
```

### Docker Compose
https://docs.docker.com/compose/install/

```sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose```

## Other Tools

### GPG

Should be already installed by this point:
- gpg (GnuPG) 2.2.12
- libgcrypt 1.8.4

### Trousseau

Download & install binary package from:
https://github.com/oleiade/trousseau/releases

### Git

```sudo apt-get install git```

### npm & packages

```bash
sudo apt-get install npm
sudo apt-get upgrade 

npm install npm@latest -g
npm install @mumbacloud/dmport
```

## SWX DevOps Environment

### Clone GitHub Repository
```git clone https://github.com/sofwerx/swx-devops.git```

### Set Up Environment
```bash
cd swx-devops
npm install
```

