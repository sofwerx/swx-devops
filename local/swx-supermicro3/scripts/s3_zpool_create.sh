#!/bin/bash
ssh root@swx-u-ub-supermicro3.local bash -c "'zpool status s3 || zpool create -m /data s3 raidz2 wwn-0x5000c50093bd6c33 wwn-0x5000c50093b9ff0f wwn-0x5000c50093bd5b77 wwn-0x5000c50093b9fc87 wwn-0x5000c50093b9c62f wwn-0x5000c50093bd686b wwn-0x5000c50093b9bf0f wwn-0x5000c50093bd6e3b wwn-0x5000c50093bd0de7'"
