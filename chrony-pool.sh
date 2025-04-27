#!/bin/bash
zypper --non-interactive remove chrony-pool-openSUSE
zypper --non-interactive addlock chrony-pool-openSUSE
zypper --non-interactive install chrony-pool-empty
