#!/bin/bash
zypper --non-interactive remove --clean-deps opensuse-welcome
zypper --non-interactive addlock opensuse-welcome
