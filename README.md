# devops

This project contains documentation and infrastructure as code for our internal devops efforts.

There are a number of tools that will need to be installed:

- aws-cli
- terraform
- gnupg
- trousseau

# aws-cli

If you are on a mac, you can install `aws-cli` with Homebrew:

    brew install aws-cli

Alternatively, or under Linux, you can use python `pip` to install it as well:

    pip install aws-cli

# ~/.aws/

The ~/.aws/ folder contains two files: `config` and `credentials`.

The `config` file contains aws-cli configurations.
The `credentials` file contains your `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` credentials.

By default, aws-cli likes to use the "default" `AWS_PROFILE`.
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
    Default region name [None]: us-east-2
    Default output format [None]: json

After entering these, you can examine your updated files:

    $ cat ~/.aws/config
    [profile sofwerx]
    output = json
    region = us-east-2

    $ cat ~/.aws/credentials
    [sofwerx]
    aws_access_key_id = AWS_ACCESS_KEY
    aws_secret_access_key = AWS_SECRET_ACCESS_KEY

Where the `AWS_ACCESS_KEY` and `AWS_SECRET_ACCESS_KEY` are the credentials you obtained by creating a key under the AWS console in IAM services for your user account.

The AWS documentation for this can be found here:

- http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html

# Running

To find out what AWS IAM user you are currently using the credentials for:

    $ aws iam get-user
    {
        "User": {
            "UserName": "Ianblenke",
            "PasswordLastUsed": "2017-10-03T13:51:54Z",
            "CreateDate": "2017-10-03T12:49:28Z",
            "UserId": "AIDAIBZNZKYZ7ISZ57FRA",
            "Path": "/",
            "Arn": "arn:aws:iam::094013511888:user/Ianblenke"
        }
    }

We use `terraform` to deploy and converge our cloud resources.

- https://www.terraform.io/


## terraform

To install the Hashicorp `terraform` command on a mac, install it with HomeBrew:

    brew install terraform

The Hashicorp Terraform site is here:

    https://www.terraform.io/

Note: It is very important that we track the same version of terraform between ourselves, and that we upgrade terraform in unison, as resources tend to change between terraform versions.
I am presently running the latest terraform: `0.10.7`.

We will be using an AWS bucket named `sofwerx-terraform` for the shared `.tfstate` files.

## gnupg

You will need a gnupg key for `trousseau` below.

To install the `gpg` command on a mac, install `gnupg` with HomeBrew:

    brew install gnupg

Installing the `gnupg` package on Linux should be as simple as one of:

    apt-get install gnupg
    yum install gnupg

After installing gnupg, you will want to generate a private/public keypair:

    gpg --gen-key

If you're like me, you'll want more than the default 2048 bits. For that, use `--full-gen-key` and override:

    gpg --full-gen-key

After doing this, please export your public key into this repo under the `gnupg/` folder with a Github Pull-Request so that everyone has access to it.

    gpg --export --armor > gnupg/ian@sofwerx.org.gpg

You can import all of our public keys at any time by running:

    gpg --import < gnupg/*

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

We will be using an AWS bucket named `sofwerx-trousseau` for the scriptable shared encrypted trousseau store.

