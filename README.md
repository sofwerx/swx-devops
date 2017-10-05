# devops

This project contains documentation and infrastructure as code for our internal devops efforts.

There are a number of tools that will need to be installed:

- awscli
- terraform
- gnupg 2.0
- trousseau

# awscli

If you are on a mac, you can install `awscli` with Homebrew:

    brew install awscli

Alternatively, or under Linux, you can use python `pip` to install it as well:

    pip install awscli

# ~/.aws/

The ~/.aws/ folder contains two files: `config` and `credentials`.

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

You will then be prompted for:

    AWS Access Key ID [None]: AWS_ACCESS_KEY
    AWS Secret Access Key [None]: AWS_SECRET_ACCESS_KEY
    Default region name [None]: us-east-1
    Default output format [None]: json

After entering these, you can examine your updated files:

    $ cat ~/.aws/config
    [profile sofwerx]
    output = json
    region = us-east-1

    $ cat ~/.aws/credentials
    [sofwerx]
    aws_access_key_id = AWS_ACCESS_KEY
    aws_secret_access_key = AWS_SECRET_ACCESS_KEY

Where the `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` are the credentials you obtained by creating a key under the AWS console in IAM services for your user account.

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

## terraform

We use `terraform` to deploy and converge our cloud resources.

- https://www.terraform.io/

To install the Hashicorp `terraform` command on a mac, install it with HomeBrew:

    brew install terraform

The Hashicorp Terraform site is here:

    https://www.terraform.io/

Note: It is very important that we track the same version of terraform between ourselves, and that we upgrade terraform in unison, as resources tend to change between terraform versions.
I am presently running the latest terraform: `0.10.7`.

We will be using an AWS bucket named `sofwerx-terraform` for the shared `.tfstate` files.

## gnupg 2.0

You will need a gnupg key for `trousseau` below.

If you happened to install `gnupg` already, just unlink first.

    brew unlink gnupg

To install the `gpg` command on a mac, install `gnupg@2.0` with HomeBrew:

    brew install gnupg@2.0
    brew link --force gnupg@2.0

The reason for gnupg 2.0 is that trousseau reads directly from `~/.gnupg/pubring.gpg`, and they did away with that file in gnupg 2.1

After installing gnupg 2.0, you will want to generate a private/public keypair:

    gpg --gen-key

If you're like me, you'll want more than the default 2048 bits. For that, use `--full-gen-key` and override:

    gpg --full-gen-key

After doing this, please export your public key into this repo under the `gnupg/` folder with a Github Pull-Request so that everyone has access to it.

    gpg --export --armor > gpg/ian@sofwerx.org

The filename _must_ be your email address, to make trousseau management easier.

You can import all of our public keys at any time by running:

    gpg --import < gpg/*

It's probably a good idea to publish your gnupg public key on some of the public key servers as well, but that's not important so long as we have access to your public key in the repo.

## trousseau

To install the `trousseau` command on a mac, install it with HomeBrew:

    brew install trousseau

Installing the `trousseau` package on Linux should be as simple as one of:

    apt-get install trousseau
    yum install trousseau

The trousseau project is here:

    https://github.com/oleiade/trousseau 

Trousseau uses gnupg to encrypt a JSON file for a number of administrators that stores "key=value" secrets.
Trousseau can use various cloud storage platforms to share these encrypted secrets between administrators.

The result of any trousseau commands will act ion the `.trousseau` file in the current proect.
This file is under .git management, and is entirely safe as the contents of the file are encrypted.
This is far easier than dealing with a shared s3 bucket or other shared repository.

## Using trousseau

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

## secrets/

The `secrets/` folder is in `.gitignore` for a reason: this holds unencrypted files that contain credentials.

After your gpg key is added, and you are added as a trousseau reciepient, you will then be able to use the trousseau command.

Our key naming convention will evolve over time.

- `file:` prefixed trousseau keys hold base64 encoded values of the content of the files.

There are 2 functions and an alias presently defined in the `.bashrc` to automate this process.

To automatically pull all of the latest trousseau `file:secrets/` prefixed files, you can use the alias:

    secrets_pull

To decrypt a specific file under secrets, I would use the following function:

    secret_decrypt secrets/ssh/sofwerx

To encrypt a file under secrets, I would use the following function:

    secret_encrypt secrets/ssh/sofwerx

After doing this, you will need to add `.trousseau` to git and commit your change so that everyone else has access to the updated secrets.

## aliases

The current reasoning behind using aliases is so that running `alias` at any time will show you a list of our "special" commands unique to this project.

This will likely evolve over time toward functions and a proper command wrapper.

# Project Environments

- [swx-dev](aws/swx-dev/README.md)

