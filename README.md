# Agama Profiles for openSUSE Leap
The [Agama](https://agama-project.github.io/) profiles in this repository are for automating a clean installation of openSUSE Leap 16.0.
They are not intended to be used *as is* by anyone except myself.

## Testing in VirtualBox
Download an ISO file from one of the following locations:

* https://download.opensuse.org/distribution/leap/16.0/installer/iso/
* https://download.opensuse.org/distribution/leap/16.0/offline/
<!-- https://download.opensuse.org/repositories/systemsmanagement:/Agama:/Devel/images/iso/ -->
<!-- https://download.opensuse.org/repositories/systemsmanagement:/Agama:/Release/images/iso/ -->

Attach the downloaded ISO to the optical drive of the virtual machine.

Start the virtual machine.

Select *UEFI Firmware Settings*\
Select *Boot Manager*\
Select *UEFI VBOX CD-ROM*\
Select *Install Leap 16.0 (x86_64)* or *Install openSUSE (x86_64)*

When the Product Selection page appears, try one of the following:

1. Press Right-Ctrl-F1 to get to the console and login as root, or
2. Press Ctrl-Alt-T to get to a terminal

```
agama download https://github.com/serock/agama-profiles/raw/main/answers.yml answers.yml
agama download https://github.com/serock/agama-profiles/raw/main/leap.jsonnet leap.jsonnet

sed -i 's/changeme/realpassphrase/' leap.jsonnet

agama questions answers /root/answers.yml
agama config generate /root/leap.jsonnet | agama config load

agama install
agama finish reboot
```

