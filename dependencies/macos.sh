if(which gpg2){
  brew unlink gnupg
}
brew install gnupg@2.0
brew link --force gnupg@2.0

brew install pinentry

git clone https://github.com/sofwerx/swx-devops
