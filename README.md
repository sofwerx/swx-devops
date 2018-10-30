# devops
> This project contains documentation and infrastructure as code for our internal devops efforts.  The following are instructions on how to prepare your computer to have access to the devops environment that runs on the [SOFWERX](https://www.sofwerx.org) server.

### Legend
  - [Installation](#installation)
    * [Docker](#docker)
    * [Vagrant](#vagrant)
    * [Windows](#windows)
  - [Security](#security)
    * [Docker](#with-docker)
    * [Manual Setup](#manual-if-not-using-docker)
    * [Trousseau](#trousseau)
  - [Using the Environment](#using-the-environment)
    * [Project Environments](#project-environments)
    * [Docker-Machine](#docker-machine-and-dm)
    * [AWS](#aws)
    * [SWX](#information-about-swx)
    * [Trousseau](#using-trousseau)
    * [Terraform](#terraform)

# Installation

There are a number of tools that will need to be installed:

- [awscli](#awscli)
- [docker](#docker)
- [docker-compose](#docker)
- [docker-machine (optional)](#docker)
- [gnupg 2.0](#gnupg)
- [terraform](#terraform)
- [trousseau](#trousseau)

The easiest way to gain access to the devops environment is by using Docker.  This project uses Docker heavily. You will find `docker-compose.yml` files in the environment directories.

## Docker

### Mac

[HomeBrew](https://brew.sh) makes it easy to update:
   
   ```bash
   brew install docker docker-machine docker-compose docker-machine-driver-xhyve
   ```

For more information see: [Docker for Mac](https://docs.docker.com/docker-for-mac/install/).

### Other Operating Systems

Please refer to these links for the most up-to-date installation instructions for Docker:

- [Docker](https://docs.docker.com/engine/installation/)
- [docker-machine](https://docs.docker.com/machine/install-machine/#installing-machine-directly)
- [docker-compose](https://docs.docker.com/compose/install/)


### After Docker installation
1. Clone the [devops](https://github.com/sofwerx/swx-devops.git) repository. 
   - For guidance on cloning a repository click [here](https://help.github.com/articles/cloning-a-repository/).

2. Run `./docker.sh` in the new swx-devops directory. 

3. Verify that you are in the devops environment by typing `swx` .

## Vagrant
> Only use if Docker is not applicable. 

### Linux

1. Install [Vagrant](https://www.vagrantup.com/) and [install a local virtual machine (VM)](https://www.vagrantup.com/docs/installation/).

2. There is a `Vagrantfile` that prepares a Ubuntu environment using the `./dependencies/ubuntu.sh` script:

    ```bash
    vagrant up
    ```
    ```bash
    vagrant ssh
    ```

### Windows
> For Windows, you need to install Windows Subsystem for Linux.

#### On 64-bit Windows 10 Anniversary Update or later (build 1607+)

Please refer to the documentation below for the most up-to-date instructions:
- [About the Windows Subsystyem for Linux ](https://msdn.microsoft.com/en-us/commandline/wsl/about)
- [Instructions for installing the Windows Subsystem for Linux](https://msdn.microsoft.com/en-us/commandline/wsl/install-win10)

This runs Linux binaries natively without having to run a VM for a Linux kernel.

1. Enable the Windows Subsystem for Linux:

    ```
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    ```

2. After selecting Ubuntu as your favorite Linux distribution, and following the prompts and rebooting, open a Command Prompt and run `bash`:

    ```
    C:\> bash
    ```

3. Now you can `cd` into the directory where you cloned this git repository, and run:

    ```
    bash$ ./dependencies/ubuntu.sh
    ```

Note: Windows Subsystem for Linux:
- It is not possible to run a Linux docker-engine without a Linux kernel.
- You are installing docker-engine natively on Windows so that you have a local Hyper-V Linux VM to run that kernel.

4. Once you install a local docker-engine with volume share access to this working directory, then you can proceed. The key here is having a local docker-engine installed that has volume mount access to this directory.

# Security

## Secrets

This git repository stores the secrets for the above Project Environments in the `.trousseau` file in this git repository.

This file is `gpg` encrypted using `trousseau`. To use these secrets, you will need to have your gpg public key listed in the `gpg/` folder.

The `secrets/` folder is in `.gitignore` for a reason: this holds unencrypted files that contain credentials.

No files under `secrets/` should ever be committed to this git repo. Any secrets will be pulled out of `trousseau` by the `swx` commands as necessary.

### With Docker

If using Docker, just make the `secrets/gnupg` in the repo directory and run `./docker.sh`.

### Manual (if not using Docker)

#### gnupg

You need a gnupg key for `trousseau` below.

The reason for gnupg 2.0 is trousseau reads directly from `pubring.gpg`, and is no longer supported in gnupg 2.1 and newer.

#### Mac

There is a `gpg` built-in to MacOS in `/usr/bin/gpg`, and that is incompatible with `trousseau`.

1. Install `gpg` v2.0 to /usr/local/bin (until we can submit a PR to fix this in `trousseau`).

- If you happened to `brew install gnupg` already, just unlink first.

    ```
    brew unlink gnupg
    ```

2. To install the `gpg` command on a Mac, install `gnupg@2.0` with HomeBrew:

    ```bash
    brew install gnupg@2.0
    ```
    ```bash
    brew link --force gnupg@2.0
    ```

- If you also install `pinentry`, you will get a nice pop-up dialog box for your gpg passphrase:

    ```bash
    brew install pinentry
    ```

#### Ubuntu 16.04

Try running:

    ./dependencies/ubuntu.sh

That should install the correct versions of all of your dependencies.

#### Other Operating Systems

For general compatiblity and ease of developer station convergence, this project has a Vagrantfile that defines a Vagrant machine to run an Ubuntu virtual machine and install the dependencies.

[Install Vagrant for your operating system](https://www.vagrantup.com/downloads.html).

The biggest challenge managing Vagrant persistence will be syncing or sharing a folder between your host and the virtual machine.
This differs based on the virtual machine engine you use with Vagrant (VirtualBox, VMWare Workstation, VMWare Fusion, Parallels, xhyve, etc).

### GPG Configuration 

1. Create a `secrets/gnupg` directory:

    ```bash
    mkdir -p secrets/gnupg
    ```

Note: While you _can_ use the default `~/.gnupg` config folder, it is recommended to create a `secrets/gnupg` directory to keep your keychain local to this repo directory.

2. Run the `shell.bash` or `docker.sh` to enter the environment:

    `./shell.bash` OR `./docker.sh` 
    
This prepares your gnupg keychain and environment.

### GPG Verification and Key Creation
> The correct version is critical to running the program. If your keys are not configured correctly, problems will arise. 

#### Verification

To verify the correct version of gpg was installed

```bash
gpg --version
```

The version should be 2.0, nothing higher. 

#### After installing gnupg

1. Generate a private/public keypair
```bash
gpg --gen-key
```

2. While the prompt is for 2048 bits, use 4096 instead.
   -  If your `gpg` does not prompt you for the number of bits, then you're using a gnupg newer than 2.0 which will not work with trousseau.

3. After doing this, please export your public key into this repo under the `gpg/` folder with a Github Pull-Request so that everyone has access to it.

    ```bash
    gpg --export --armor > gpg/<yourname>@sofwerx.org
    ```

    ```bash
    git add gpg/<yourname>@sofwerx.org
    git commit -m 'adding gpg/<yourname>@sofwerx.org public key'
    git push
    ```    
    
- The convention in this repository is that the filename must be your email address, to make trousseau management easier.

- You can import all of our public keys at any time by running:

    ```bash
    cat gpg/* | gpg --import
    ```

4. Best practice is to publish your gnupg public key on some of the public key servers as well, but that's not important so long as we have access to your public key in the repository.

### trousseau

[Trousseau](https://github.com/oleiade/trousseau) uses gnupg to encrypt a JSON file for a number of administrators that stores "key=value" secrets.

Trousseau can use various cloud storage platforms to share these encrypted secrets between administrators.

The result of any trousseau commands will alter the `.trousseau` file in the current project.
This file is under git management, and is entirely safe as the contents of the file are encrypted.
This is far easier than dealing with a shared s3 bucket or other shared repository.

#### Installing trousseau

1. To install the `trousseau` command, download pre-built binaries from [the releases page](https://github.com/oleiade/trousseau/releases).

2. To build from the Go source follow these build instructions:

    ```bash
    mkdir ~/go/bin
    export GOPATH=~/go
    export PATH=~/go/bin:$PATH
    go get github.com/tools/godep
    go get github.com/urfave/cli
    go get github.com/oleiade/trousseau
    cd $GOPATH/src/github.com/oleiade/trousseau
    godep
    make
    cp $GOPATH/go/bin/trousseau/usr/local/bin/trousseau`
    ```
# Using the Environment

## Project Environments

These are the tools and projects that are available in the devops environment.

#### Non-cloud resources
- [Dev](local/dev/README.md) - Your local `dev` environment
- [Geo](local/geo/README.md) - Our `geo` mintpc in our Data Science pit
- [IBM Minsky](local/ibm-minsky) - The IBM Minsky box (ppc64le)
- [icbgamingpc](local/icbgamingpc) - Ian's home gaming rig
- [Mobile](local/mobile) - A mint box setup to run OpenSTF
- [Orange](local/swx-orange) - Our tranquilpc 8-blade docker swarm server in our Data Science pit
- [Osgeo](local/osgeo) - A mint box setup to run OSGEO and guacamole
- [swx-pandora](local/swx-pandora) - Pandora-FMS box
- [swx-vmhost](local/swx-vmhost) - The pop-os based System76 Silverback server
- [pi-r-squared](local/pi-r-squared/README.md) - A shared raspberry-pi docker host in our Data Science pit


#### Cloud based resources
- [Tor-vpin](https://github.com/sofwerx/tor-dfpk/tree/7fa2708a215b91ff0491c45c282a678a290b4256) - private tor network deploy for warfighter nomination


#### Archived resources
- [swx-gpu](cellar/swx-gpu/README.md) - An IBM Minsky ppc64le GPU server in our datacenter~~ (eval returned)
- [swx-dev](cellar/swx-dev/README.md) - AWS EC2 docker-engine host for various cloud deployment testing~~ (Destroyed)
- [rcloud-dev](cellar/rcloud-dev/README.md) - AWS EC2 docker-engine host for our rcloud evaluation~~ (Destroyed)
- [huntclub-moodle](cellar/huntclub-moodle) - Moodle deploy for Hunt Club (Destroyed)
- [jumpbox-kali](cellar/jumpbox-kali) - Kali guacamole jump box (Destroyed)
- [marklogic-datahub](cellar/marklogic-datahub) - Apache Nifi + Marklogic (Destroyed)
- [nerdherd-vpn](cellar/nerdherd-vpn) - Nerdherd VPN box (Destroyed)
- [swx-geotools1](cellar/swx-geotools1) - GIS Tools box (Destroyed)
- [swx-redteam](cellar/swx-redteam) - Red Team box (Destroyed)
- [swx-xmpp](cellar/swx-xmpp) - XMPP Server for ATAK (Destroyed)
- [swx-blueteam](/cellar/swx-blueteam) - Blue Team box


### docker-machine and dm
> This project imports docker-machine configs into JSON "dm" objects stored in trousseau.

The `swx dm` commands interact with these "dm" objects:

```bash
swx dm ls
```

- This lists the dm file secrets stored in trousseau under `file:secrets/dm/*`

To source one of the environments, use `swx dm env`.

To source a specific dm:

```bash
swx dm env rcloud-dev-00
```

- This acts similar to a `eval $(docker-machine env {machinename})`.

To create a dm, first create a machine with `docker-machine`, then use `swx dm import` to export it:

```bash
docker-machine create -d generic \
--generic-ip-address 192.168.14.194 \ 
--generic-ssh-key ${devops}/secrets/ssh/sofwerx \
--generic-ssh-user pi \ 
--engine-storage-driver overlay2 swx-pi
```

```bash
swx dm import swx-pi
```

Then `git add .trousseau ; git commit` to save the newly added dm secret.

## AWS
> This project models some cloud resources under the `aws/` folder.

### awscli

#### Mac

Install `awscli` with Homebrew:

```bash
brew install awscli
```
#### Other Operating Systems

Use Python `pip`:

```bash
pip install awscli
```

## Choosing  between `~/.aws/` and `secrets/aws`

If you make a `secrets/aws` folder, your secrets will be stored there, instead of `~/.aws/`:

```bash
mkdir secrets/aws
```

The `~/.aws/` folder, or `secrets/aws` folder, contains two files: `config` and `credentials`.

The `config` file contains awscli configurations.
The `credentials` file contains your `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` credentials.

By default, awscli likes to use the "default" `AWS_PROFILE`.
Our `shell.bash` assumes using an `AWS_PROFILE` name of "sofwerx".

This enables you to manage multiple profiles for different AWS credentials under different profiles.

1. Either create these files with a text editor (they are in an .ini file format internally) as described below or use the following commands:

```bash
mkdir secrets/aws
touch secrets/aws/config secrets/aws/credentials
aws configure --profile sofwerx
```

2. At the prompt enter:

    AWS Access Key ID [None]: AWS_ACCESS_KEY
    AWS Secret Access Key [None]: AWS_SECRET_ACCESS_KEY
    Default region name [None]: us-east-1
    Default output format [None]: json

3. After entering these, you can examine your updated files:

    ```bash
    $ cat ~/.aws/config secrets/aws/config
    [profile sofwerx]
    output=json
    region=us-east-1
    ```

    ```bash
    $ cat ~/.aws/credentials secrets/aws/credentials
    [sofwerx]
    aws_access_key_id=<AWS_ACCESS_KEY>
    aws_secret_access_key=<AWS_SECRET_ACCESS_KEY>
    ```

Where the `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` are the credentials you obtained by creating a key under the AWS console in IAM services for your user account.

5. After doing this, make sure to restart your `shell.bash` to pick up these environment variables in your shell.

The AWS documentation for this can be found [here](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html).

### Running AWS

To find out what AWS IAM user you are currently using the credentials for:

```bash
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
``` 

### `.bashrc`

The "glue" of this harness is currently in the `.bashrc` file.

This will eventually get broken out into a script directory tree as simplicity demands it.

### `shell.bash`

Before running trousseau or any other tools against a project environment, obtain a shell using `shell.bash`:

```bash
icbmbp:swx-devops ianblenke$ ./shell.bash
```
You will get a prompt that tells you the `AWS_PROFILE`, `SWX_ENVIRONMENT`, and `DOCKER_MACHINE_NAME` variables:

```bash
[sofwerx::] icbvtcmbp:swx-devops ianblenke$
```

### Information about `swx`
> Before attempting `swx` commands, remember to be in the environment (run `shell.bash` or `docker.sh`). 

When running under `shell.bash`, which merely sources the `.bashrc` here, your primary interaction with this harness is through the `swx` command.

Implemented as a series of bash functions, the `swx` command has _full tab completion_, which makes it easier to interact with the components in this harness.

The `swx` command also has full usage instructions. Run the commands without arguments, and usage will be shown:

```bash
$ swx
  Usage: swx {command}
    dm          - Manage dm (docker-machines)
    environment - Source project-lifecycle environment variables
    gpg         - Interact with your gpg-agent
    secrets     - Deal with secrets/ folder
    ssh         - Attempt to ssh into a dm
    tf          - Run Terraform for a project-lifecycle
```
    
This also works for subcommands:

```bash
$ swx dm
  Usage: swx dm {action}
    ls     - List dm instances
    env    - Source the environment to interact with a dm instance using docker
    import - Import a docker-machine instance into a dm
``` 

### Using trousseau
> Make sure you are in a `shell.bash` or a `docker.sh` session.

By default `trousseau` will use a `~/.trousseau` file in your home directory.
Using a `shell.bash` session, the `.trousseau` file in this project will be used and updated as things are changed.
This is essential to contribute the changes back to the git repository for others to use.

1. After your `gpg/<yourname>@sofwerx.org` pull request is merged, get someone else, who is already a trusted trousseau recipient, to add your public key to their keychain and run `trousseau add-recipient` for your email address:

```bash
trousseau add-recipient yourname@sofwerx.org
```

2. After this, they need to:

```bash
git add .trousseau
git commit -m 'Added ian@sofwerx.org to recipients'
```

Now future trousseau operations will also be encrypted for you to be able to see with your gpg key.

#### Commands

To set a trousseau key:

```bash
trousseau set myvariable somevalue
```
To retrieve the value for a key:

```bash
trousseau get myvariable
```
To delete a key:

```bash
trousseau del myvariable
```

Running `trousseau` on its own will show the other usable commands.

#### Use with gpg

The `.trousseau` file in this project is the actual gpg encrypted contents used to manage our environments.
If you fork this repo, you need to remove `.trousseau` and create a new one with `trousseau create {gpg key email or id}`.

After your gpg key is added, and you are added as a trousseau reciepient, you will be able to use the trousseau command.

#### Naming Convention

- `file:` prefixed trousseau keys hold base64 encoded values of the content of the files.
- `environment:` prefixed trousseau keys hold environment variables for terraform to use

#### Automation

There are two functions and an alias presently defined in the `.bashrc` to automate the process.

To automatically pull all of the latest trousseau `file:secrets/` prefixed files:

```bash
swx secrets pull
```

To decrypt a specific file under secrets:

```bash
swx secrets decrypt secrets/ssh/sofwerx
```

To encrypt a file under secrets:

```bash
swx secrets encrypt secrets/ssh/sofwerx
```

After doing this, you will need to add `.trousseau` to git and commit your change so that everyone else has access to the updated secrets.

### Using `swx`

The `swx` function commands are available when you start a `shell.bash` session.

Your primary interaction will be through the `swx` function. Run a command and it will show usage for that command:

```bash
$ swx
  Usage: swx {command}
    dm          - Manage dm (docker-machines)
    environment - Source project-lifecycle environment variables
    secrets     - Deal with secrets/ folder
    tf          - Run Terraform for a project-lifecycle
    dc          - Run docker-compose for a project-lifecycle
``` 

The `swx` command also has bash tab completion.

Note, that there is no selected `SWX_ENVIRONMENT` yet. To select `swx-dev`, you would use this function:

```bash
swx environment switch swx-dev
```

This could look something like:

```bash
[sofwerx::] icbvtcmbp:swx-devops ianblenke$ swx environment switch swx-dev
[sofwerx:swx-dev:] icbvtcmbp:swx-devops ianblenke$
```

Also note, that there is no selected `DOCKER_MACHINE_NAME` yet. To select `swx-dev`, use this function:

```bash
swx dm env swx-dev-0
```

Which could look something like:

```bash
[sofwerx:swx-dev:] icbvtcmbp:swx-devops ianblenke$ swx dm env swx-dev
[sofwerx:swx-dev:swx-dev-0] icbvtcmbp:swx-devops ianblenke$
```

Now you are ready to run any `docker-compose` commands in the correct folders.

If you are switching between environments, it will ensure that any variables defined in the previous environment are unset before setting the new environment's variables to be used.

#### Using `swx gpg`

When using the `swx` or `trousseau` commands that require access to the trousseau secrets, the `gpg-agent` prompts you for a passphrase.

If you enter this passphrase incorrectly, these commands will fail until you "repair" your `gpg-agent`; which will not prompt you for another passphrase until the ttl expires, which is quite long.

The `swx gpg` commands are meant to deal with this condition:

- `swx prepare`  - Prepare your gpg-agent environment
- `swx remember` - Remember your passphrase (gpg-agent)
- `swx forget`   - Forget your passphrase (gpg-agent)
- `swx reset`    - Reset your gpg-agent

The exact sequence of which command to use depends on the state of your `gpg-agent` is.

Typically, try a `swx forget` followed by an `swx remember` first, and see if the commands work after you enter your passphrase.

If this fails, try a `swx reset` followed by a `swx prepare`, which will restart `gpg-agent` and hopefully let you enter a passphrase the next time you try using an `swx` or `trousseau` command that requires access to your trousseau secrets.

#### The `swx environment`

In addition to listing (`swx environment ls`) and switching (`swx environment switch ENVIRONMENT`), there are a few other `swx environment` commands for dealing with `environment:` prefixed trousseau keys that store environment variables for environments:

```bash
swx environment keys
swx environment get VARIABLE
swx environment set VARIABLE VALUE
swx environment del VARIABLE
```

### terraform

Use [terraform](https://www.terraform.io/) to deploy and converge our cloud resources.

#### Mac Installation

To install the Hashicorp `terraform`, install it with HomeBrew:

```bash
brew install terraform
```    

#### Other operating systems

Please refer to the [offical documentation](https://www.terraform.io/intro/getting-started/install.html).

#### Tips for using terraform. 

It is very important that we track the same version of terraform between ourselves, and that we upgrade terraform in unison, as resources tend to change between terraform versions.
I am presently running the latest terraform: `0.10.7`.

Internally, we use an AWS bucket named `sofwerx-terraform` for the shared `.tfstate` files. You will see how to set those up in the README.md for each environment.

Instead of using `terraform` directly, I strongly suggest using the `swx tf` wrapper instead, as it will ensure that you have the correct environment sourced before running `terraform`.
