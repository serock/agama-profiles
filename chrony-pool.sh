#!/bin/bash
zypper --non-interactive remove --clean-deps chrony-pool-openSUSE
zypper --non-interactive addlock chrony-pool-openSUSE
zypper --non-interactive install chrony-pool-empty
