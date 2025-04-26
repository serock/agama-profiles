#!/bin/bash
zypper install openSUSE-repos-Leap
zypper refresh --services
zypper modifyrepo --disable openSUSE:repo-non-oss openSUSE:update-non-oss
