#!/bin/bash
ssh root@swx-u-ub-supermicro3.local bash -c "'zpool status s4 || zpool create -m /data -o ashift=12 s4 raidz3 wwn-0x5000c50093bd03d3 wwn-0x5000c50093bd6177 wwn-0x5000c50093bd9a7b wwn-0x5000c50093bd61b7 wwn-0x5000c50093bd91eb wwn-0x5000c50093bd88cb wwn-0x5000c50093bd950b wwn-0x5000c50093bd081b wwn-0x5000c50093bd703f wwn-0x5000c50093bd0e1b wwn-0x5000c50093bd7f33 wwn-0x5000c50093b9d907'"
