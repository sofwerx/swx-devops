# travis-ci

This directory contains the convergence harness for travis-ci.

As there is no good travis-ci provider for terraform yet, the best approach is to embrace the travis.rb client:

https://github.com/travis-ci/travis.rb

This can be installed by running:

    bundle install

https://github.com/babbel/terraform-provider-travisci

Before running terraform, you will need to install the travisci provider. To do that, you will first need to install Go v1.8 or later and have a `GOPATH` environment variable already set.

Then:

    git clone git@github.com:babbel/terraform-provider-travisci $GOPATH/src/github.com/babbel/terraform-provider-travisci
    make build

