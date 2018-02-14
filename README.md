# devops

This project contains documentation and infrastructure as code for our internal devops efforts.

There are a number of tools that will need to be installed:

- awscli
- terraform
- gnupg 2.0
- trousseau
- docker
- docker-compose
- docker-machine (optional)

Or you can install Vagrant and spin up a VM:

    https://www.vagrantup.com/

There is a `Vagrantfile` in this project that should prepare a functional ubuntu environment using the `./dependencies/ubuntu.sh` script:

    vagrant up
    vagrant ssh

The dependencies, and how to use them, are enumerated below.

# Project Environments

Non-cloud resources:

- [local/dev](local/dev/README.md) - Your local `dev` environment
- [local/geo](local/geo/README.md) - Our `geo` mintpc in our Data Science pit
- [local/ibm-minsky](local/ibm-minsky) - The IBM Minsky box (ppc64le)
- [local/icbgamingpc](local/icbgamingpc) - Ian's home gaming rig
- [local/mobile](local/mobile) - A mint box setup to run OpenSTF
- [local/orange](local/orange/README.md) - Our tranquilpc 8-blade docker swarm server in our Data Science pit
- [local/osgeo](local/osgeo) - A mint box setup to run OSGEO and guacamole
- [local/swx-pandora](local/swx-pandora) - Pandora-FMS box
- [local/vmhost](local/vmhost) - The pop-os based System76 Silverback server
- [local/pi-r-squared](local/pi-r-squared/README.md) - A shared raspberry-pi docker host in our Data Science pit
- ~~[local/swx-gpu](local/swx-gpu/README.md) - An IBM Minsky ppc64le GPU server in our datacenter~~ (eval returned)

Cloud based resources:

- [aws/huntclub-moodle](aws/huntclub-moodle) - Moodle deploy for Hunt Club
- [aws/jumpbox-kali](aws/jumpbox-kali) - Kali guacamole jump box
- [aws/marklogic-datahub](aws/marklogic-datahub) - Apache Nifi + Marklogic
- [aws/nerdherd-vpn](aws/nerdherd-vpn) - Nerdherd VPN box
- [aws/swx-blueteam](aws/swx-blueteam) - Blue Team box
- [aws/swx-geotools1](aws/swx-geotools1) - GIS Tools box
- [aws/swx-redteam](aws/swx-redteam) - Red Team box
- [aws/swx-xmpp](aws/swx-xmpp) - XMPP Server for ATAK
- ~~[aws/swx-dev](aws/swx-dev/README.md) - AWS EC2 docker-engine host for various cloud deployment testing~~ (Destroyed)
- ~~[aws/rcloud-dev](aws/rcloud-dev/README.md) - AWS EC2 docker-engine host for our rcloud evaluation~~ (Destroyed)

# Secrets

This git repo stores the secrets for the above Project Environments in the `.trousseau` file in this git repository.

This file is `gpg` encrypted using `trousseau`. To use these secrets, you will need to have your gpg public key listed in the `gpg/` folder. How to do accomplish that is enumerated in detail below.

## secrets/

The `secrets/` folder is in `.gitignore` for a reason: this holds unencrypted files that contain credentials.

No files under `secrets/` should ever be committed to this git repo. Any secrets will be pulled out of `trousseau` by the `swx` commands as necessary.

## gnupg 2.0

You will need a gnupg key for `trousseau` below.

The reason for gnupg 2.0 is that trousseau reads directly from `pubring.gpg`, and they did away with that file in gnupg 2.1 and newer.

### On a Mac

There is a `gpg` built-in to MacOS in `/usr/bin/gpg`, and that is too new for `trousseau` now.

We want to install `gpg` v2.0 to /usr/local/bin (until we can submit a PR to fix this in trousseau).

If you happened to `brew install gnupg` already, just unlink first.

    brew unlink gnupg

To install the `gpg` command on a mac, install `gnupg@2.0` with HomeBrew:

    brew install gnupg@2.0
    brew link --force gnupg@2.0

If you also install pinentry, you will get a nice pop-up dialog box for your gpg passphrase:

    brew install pinentry

### On Ubuntu 16.04

Try running:

    ./dependencies/ubuntu.sh

That should install the correct versions of all of your dependencies.

### On 64-bit Windows 10 Anniversary Update or later (build 1607+)

You will want to run the Windows Subsystem for Linux:

- https://msdn.microsoft.com/en-us/commandline/wsl/about
- https://msdn.microsoft.com/en-us/commandline/wsl/install-win10

This will run linux binaries natively without having to run a virtual machine for a linux kernel.

To enable the Windows Subsystem for Linux:

    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

After selecting Ubuntu as your favorite Linux distribution, and following the prompts and rebooting, you should be able to open a Command Prompt and run `bash`:

    C:\> bash

Now you can `cd` into the directory where you cloned this git repo, and run:

    bash$ ./dependencies/ubuntu.sh

### On other operating systems

For general compatiblity and ease of developer station convergence, this project has a Vagrantfile that defines a Vagrant machine to run an Ubuntu virtual machine and install our dependencies.

Install Vagrant for your operating system:

- https://www.vagrantup.com/downloads.html

The biggest challenge managing Vagrant persistence will be syncing or sharing a folder between your host and the virtual machine.
This differs based on the virtual machine engine you use with Vagrant (VirtualBox, VMWare Workstation, VMWare Fusion, Parallels, xhyve, etc).

While you _can_ use the default `~/.gnupg` config folder, I strongly suggest creating a `secrets/gnupg` directory to keep your keychain local to this repo directory:

    mkdir -p secrets/gnupg

Now run the `shell.bash` to enter the environment:

    ./shell.bash

This will prepare your gnupg keychain and environment.

After installing gnupg 2.0, you will want to generate a private/public keypair:

    gpg --gen-key

When prompted for 2048 bits, it's a good idea to use 4096 instead.
If your `gpg` does not prompt you for the number of bits, you're probably using a gnupg newer than 2.0 which will not work with trousseau.

After doing this, please export your public key into this repo under the `gpg/` folder with a Github Pull-Request so that everyone has access to it.

    gpg --export --armor > gpg/yourname@sofwerx.org
    git add gpg/yourname@sofwerx.org
    git commit -m 'Adding gpg/yourname@sofwerx.org public key'

Our convention in this repository is that the filename must be your email address, to make trousseau management easier.

You can import all of our public keys at any time by running:

    cat gpg/* | gpg --import

It's probably a good idea to publish your gnupg public key on some of the public key servers as well, but that's not important so long as we have access to your public key in the repo.

## trousseau

Trousseau uses gnupg to encrypt a JSON file for a number of administrators that stores "key=value" secrets.

Trousseau can use various cloud storage platforms to share these encrypted secrets between administrators.

The result of any trousseau commands will alter the `.trousseau` file in the current proect.
This file is under git management, and is entirely safe as the contents of the file are encrypted.
This is far easier than dealing with a shared s3 bucket or other shared repository.

The trousseau project is here:

- https://github.com/oleiade/trousseau 

To install the `trousseau` command, you can download pre-built binaries from the releases page:

- https://github.com/oleiade/trousseau/releases

You can build from the Go source by following the build instructions, summarized here:

    mkdir ~/go/bin
    export GOPATH=~/go
    export PATH=~/go/bin:$PATH 
    go get github.com/tools/godep
    go get github.com/urfave/cli
    go get github.com/oleiade/trousseau
    cd $GOPATH/src/github.com/oleiade/trousseau
    godep
    make
    cp $GOPATH/go/bin/trousseau /usr/local/bin/trousseau

# AWS

This project models some cloud resources under the `aws/` folder.

## awscli

If you are on a mac, you can install `awscli` with Homebrew:

    brew install awscli

Alternatively, or under Linux, you can use python `pip` to install it as well:

    pip install awscli

# `~/.aws/` or `secrets/aws`

If you make a `secrets/aws` folder, your secrets will be stored there, instead of `~/.aws/`:

    mkdir secrets/aws

The `~/.aws/` folder, or `secrets/aws` folder, contains two files: `config` and `credentials`.

The `config` file contains awscli configurations.
The `credentials` file contains your `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` credentials.

By default, awscli likes to use the "default" `AWS_PROFILE`.
Our `shell.bash` assumes that you will be using an `AWS_PROFILE` name of "sofwerx".

The reasoning here is that you can manage multiple profiles for different AWS credentials under different profiles.

You can either create these files with a text editor (they are in an .ini file format internally) as decribed below,
or you can use the following commands to prompt you:

    mkdir ~/.aws
    touch ~/.aws/config ~/.aws/credentials
    aws configure --profile sofwerx

or

    mkdir secrets/aws
    touch secrets/aws/config secrets/aws/credentials
    aws configure --profile sofwerx

You will then be prompted for:

    AWS Access Key ID [None]: AWS_ACCESS_KEY
    AWS Secret Access Key [None]: AWS_SECRET_ACCESS_KEY
    Default region name [None]: us-east-1
    Default output format [None]: json

After entering these, you can examine your updated files:

    $ cat ~/.aws/config secrets/aws/config
    [profile sofwerx]
    output = json
    region = us-east-1

    $ cat ~/.aws/credentials secrets/aws/credentials
    [sofwerx]
    aws_access_key_id = AWS_ACCESS_KEY
    aws_secret_access_key = AWS_SECRET_ACCESS_KEY

Where the `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` are the credentials you obtained by creating a key under the AWS console in IAM services for your user account.

After doing this, you should exit your `shell.bash` and run it again to pick up these environment variables in your shell.

The AWS documentation for this can be found here:

- http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

## Running `aws`

To find out what AWS IAM user you are currently using the credentials for:

    $ aws iam get-user
    {
        "User": {
            "UserName": "ianblenke",
            "PasswordLastUsed": "2017-10-03T13:51:54Z",
            "CreateDate": "2017-10-03T12:49:28Z",
            "UserId": "AIDAREDACTED2REDACTED",
            "Path": "/",
            "Arn": "arn:aws:iam::123456789012:user/ianblenke"
        }
    }


## .bashrc

The "glue" of this harness is currently in the `.bashrc` file.

The `swx` command provides the interface to the functions that interact with this devops harness:

    $ swx
    Usage: swx {command}
      gpg         - Interact with your gpg-agent
      dm          - Manage dm (docker-machines)
      environment - Source project-lifecycle environment variables
      secrets     - Deal with secrets/ folder
      tf          - Run Terraform for a project-lifecycle

This will eventually get broken out into a script directory tree as simplicity demands it.

## `shell.bash`

Before running trousseau or any other tools against a project environment, you will need to obtain a shell using `shell.bash` first:

    icbmbp:swx-devops ianblenke$ ./shell.bash

After doing this, you will get a prompt that tells you the `AWS_PROFILE`, `SWX_ENVIRONMENT`, and `DOCKER_MACHINE_NAME` variables like so:

    [sofwerx::] icbvtcmbp:swx-devops ianblenke$

## Using trousseau

First, ensure you are in a `shell.bash` session.

By default `trousseau` will use a `~/.trousseau` file in your home directory.
Using a `shell.bash` session, the `.trousseau` file in this project will be used and updated as you change things.
We want this so that we can contribute the changes back to the git repo for others to use.

After your gpg/ PR is merged, you need to get someone else who is already a trusted trousseau recipient to add your public key to their keychain and then run `trousseau add-recipient` for your email address:

    trousseau add-recipient ian@sofwerx.org

After this, they need to:

    git add .trousseau
    git commit -a -m 'Added ian@sofwerx.org to recipients'

Now future trousseau operations will also be encrypted for you to be able to see with your gpg key.

To set a trousseau key:

    trousseau set myvariable somevalue

To retrieve the value for a key:

    trousseau get myvariable

To delete a key:

    trousseau del myvariable

Running `trousseau` on its own will show the other usable commands.

The `.trousseau` file in this project is the actual gpg encrypted contents used to manage our environments.
If you fork this repo to use yourself, you will need to remove `.trousseau` and create a new one with `trousseau create {gpg key email or id}`

After your gpg key is added, and you are added as a trousseau reciepient, you will then be able to use the trousseau command.

Our key naming convention will evolve over time.

- `file:` prefixed trousseau keys hold base64 encoded values of the content of the files.
- `environment:` prefixed trousseau keys hold enviroment variables for terraform to use

There are 2 functions and an alias presently defined in the `.bashrc` to automate this process.

To automatically pull all of the latest trousseau `file:secrets/` prefixed files, you can use:

    swx secrets pull

To decrypt a specific file under secrets, I would use the following function:

    swx secrets decrypt secrets/ssh/sofwerx

To encrypt a file under secrets, I would use the following function:

    swx secrets encrypt secrets/ssh/sofwerx

After doing this, you will need to add `.trousseau` to git and commit your change so that everyone else has access to the updated secrets.

## `swx`

The `swx` function commands are available when you start a `shell.bash` session.

Your primary interaction will be through the `swx` function. You can run a command and it should show usage for that command:

    $ swx
    Usage: swx {command}
      dm          - Manage dm (docker-machines)
      environment - Source project-lifecycle environment variables
      secrets     - Deal with secrets/ folder
      tf          - Run Terraform for a project-lifecycle
      dc          - Run docker-compose for a project-lifecycle

The `swx` command also has very helpful bash tab completion.

Note that there is no selected `SWX_ENVIRONMENT` yet. To select `swx-dev`, you would use this function:

    swx environment switch swx-dev

This would look something like:

    [sofwerx::] icbvtcmbp:swx-devops ianblenke$ swx environment switch swx-dev
    [sofwerx:swx-dev:] icbvtcmbp:swx-devops ianblenke$

Also note that there is no selected `DOCKER_MACHINE_NAME` yet. To select `swx-dev`, you would use this function:

    swx dm env swx-dev-0

Which would look something like:

    [sofwerx:swx-dev:] icbvtcmbp:swx-devops ianblenke$ swx dm env swx-dev
    [sofwerx:swx-dev:swx-dev-0] icbvtcmbp:swx-devops ianblenke$

Now I am ready to run any `docker-compose` commands in the correct folders.

If you are switching between environments, it will ensure that any variables defined in the previous environment are unset before setting the new environment's variables to be used.

### `swx gpg`

When you use the `swx` or `trousseau` commands that require access to the trousseau secrets, your `gpg-agent` will prompt you for a passphrase.

If you enter this passphrase incorrectly, these commands will fail until you "repair" your `gpg-agent` which will not prompt you for another passphrase until the ttl expiry, which is quite long.

The `swx gpg` commands are meant to deal with this condition:

- `swx prepare`  - Prepare your gpg-agent environment
- `swx remember` - Remember your passphrase (gpg-agent)
- `swx forget`   - Forget your passphrase (gpg-agent)
- `swx reset`    - Reset your gpg-agent

The exact sequence of which command to use depends on what the state of your `gpg-agent` is.

Typically, try a `swx forget` followed by an `swx remember` first, and see if the commands work after you enter your passphrase.

If this fails, try a `swx reset` followed by a `swx prepare`, which will restart `gpg-agent` and hopefully let you enter a passphrase the next time you try using an `swx` or `trousseau` command that requires access to your troussea secrets.

### `swx environment`

In addition to listing (`swx enviroment ls`) and switching (`swx enviroment switch ENVIRONMENT`), there are a few other `swx environment` commands 
for dealing with `environment:` prefixed trousseau keys that store environment variables for enviroments:

    swx enviroment keys
    swx enviroment get VARIABLE
    swx enviroment set VARIABLE VALUE
    swx enviroment del VARIABLE

## terraform

We use `terraform` to deploy and converge our cloud resources.

- https://www.terraform.io/

To install the Hashicorp `terraform` command on a mac, install it with HomeBrew:

    brew install terraform

The Hashicorp Terraform site is here:

    https://www.terraform.io/

Note: It is very important that we track the same version of terraform between ourselves, and that we upgrade terraform in unison, as resources tend to change between terraform versions.
I am presently running the latest terraform: `0.10.7`.

Internally, we use an AWS bucket named `sofwerx-terraform` for the shared `.tfstate` files. You will see how to set those up in the README.md for each environment.

Instead of using `terraform` directly, I strongly suggest using the `swx tf` wrapper instead, as it will ensure that you have the correct environment sourced before running `terraform`.

# Docker

This project uses docker heavily. You will find `docker-compose.yml` files in the environment directories.

## docker

You will want to first install docker.

For Mac, I use HomeBrew to make it easy to update to the latest:

    brew install docker docker-machine docker-compose docker-machine-driver-xhyve

That being said, I also recommend trying out Docker for Mac.

   https://docs.docker.com/docker-for-mac/install/

For Windows and Linux, it's just easiest to follow the directions for CE:

- https://docs.docker.com/engine/installation/
- https://docs.docker.com/machine/install-machine/#installing-machine-directly
- https://docs.docker.com/compose/install/

Note: For the Linux Subsystem for Windows:
- It is not possible to run a linux docker-engine without a linux kernel.
- You are installing docker-engine natively on Windows so that you have a local Hyper-V linux virtual machine to run that kernel.
- Installing `./dependencies/ubuntu.sh` earlier should have already installed the docker/docker-compose/docker-machine command-line tools for you in your bash shell for talking to remote docker engines.

## docker-machine vs dm

This project will import docker-machine configs into JSON "dm" objects stored in trousseau.

The `swx dm` commands interact with these "dm" objects:

    swx dm ls

This will list the dm file secrets stored in trousseau under `file:secrets/dm/*`

In order to source one of the environments, you can use `swx dm env` do source a specific dm:

    swx dm env rcloud-dev-00

This acts similar to a `eval $(docker-machine env {machinename})`.

To create a dm, you would first create a machine with `docker-machine`, and then use the `swx dm import` command to export it:

    docker-machine create -d generic --generic-ip-address 192.168.14.194 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user pi --engine-storage-driver overlay2 swx-pi
    swx dm import swx-pi

Then you would want to `git add .trousseau ; git commit` to save that newly added dm secret.

