#!/bin/bash
if [ ! -d .terraform ] ; then
  terraform init --backend-config="key=marklogic/datahub/terraform.tfstate"
fi
