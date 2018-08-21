#!/bin/bash
ssh root@swx-u-ub-supermicro0.local bash -c "'zpool status s0 || zpool create -m /data s0 -o ashift=12 raidz3 wwn-0x5000c50093bda21b wwn-0x5000c50093bd77af wwn-0x5000c50093bd71e3 wwn-0x5000c50093bd88f7 wwn-0x5000c50093bcf66b wwn-0x5000c50093bd5c2f wwn-0x5000c50093bd68eb wwn-0x5000c50093bd602b wwn-0x5000c50093bd5e5b wwn-0x5000c50093bd4e47 wwn-0x5000c50093bd71c3 wwn-0x5000c50093bd6ac7'"
