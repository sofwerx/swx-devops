#!/bin/bash

set -e

which gpg2 > /dev/null ||
  brew unlink gnupg


brew install gnupg@2.0
brew link --force gnupg@2.0

brew install pinentry

git clone https://github.com/sofwerx/swx-devops
