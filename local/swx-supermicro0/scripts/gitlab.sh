#!/bin/bash
ssh root@swx-u-ub-supermicro0.local zfs create s0/gitlab
ssh root@swx-u-ub-supermicro0.local zfs create s0/gitlab/config
ssh root@swx-u-ub-supermicro0.local zfs create s0/gitlab/logs
ssh root@swx-u-ub-supermicro0.local zfs create s0/gitlab/data
