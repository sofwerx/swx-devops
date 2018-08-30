#!/bin/bash
ssh root@swx-u-ub-supermicro2.local bash -c "'zpool create -f -m /data s2 -o ashift=12 raidz3 wwn-0x5000c50093bd0a87 wwn-0x5000c50093bd89d7 wwn-0x5000c50093bd6827 wwn-0x5000c50093bd924f wwn-0x5000c50093bd7c17 wwn-0x5000c50093bd5b93 wwn-0x5000c50093bd6fb3 wwn-0x5000c50093bd64ff wwn-0x5000c50093bd54ff wwn-0x5000c50093bd87af wwn-0x5000c50093bd91b7 wwn-0x5000c50093bd64f7'"
