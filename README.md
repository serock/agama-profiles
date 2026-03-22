# Agama Profiles for openSUSE Leap
The [Agama](https://agama-project.github.io/) profiles in this repository are for automating a clean installation of openSUSE Leap 16.1.
They are not intended to be used *as is* by anyone except myself.

## Testing in VirtualBox
Download an **online** ISO file from the following location:

* https://download.opensuse.org/distribution/leap/16.1/offline/

Attach the downloaded ISO to the optical drive of the virtual machine.

Start the virtual machine.

Select *UEFI Firmware Settings*\
Select *Boot Manager*\
Select *UEFI VBOX CD-ROM*\
Select *Install Leap 16.1 (x86_64)*

When the Product Selection page appears, try one of the following, press Right-Ctrl-F1 to get to the console and login as root.

```
agama download https://github.com/serock/agama-profiles/raw/main/leap.jsonnet leap.jsonnet

sed -i 's/changeme/realpassphrase/' leap.jsonnet

agama config generate /root/leap.jsonnet | agama config load

agama install
agama finish reboot
```

