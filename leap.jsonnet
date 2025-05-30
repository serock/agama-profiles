local agama = import "hw.libsonnet";
local board = agama.findByID(agama.lshw, "core").product;
local getHostname() =
  if board == "PRIME H370M-PLUS" then
    "desktop"
  else if board == "4239CTO" then
    "laptop15"
  else if board == "IPXBD-RB" then
    "mini"
  else if board == "VirtualBox" then
    "vbox"
  else
    "agama";
// Clue: https://github.com/agama-project/agama/blob/cfa8d9057004d279508241febf5e97a344300350/rust/agama-lib/share/examples/profile.jsonnet#L15
local drive = std.sort(
  std.filter(
    function(d) std.objectHas(d, "size"),
    agama.selectByClass(agama.lshw, "disk")),
  function(x) -x.size)[0].logicalname;

{
  product: {
    // Clue: https://github.com/agama-project/agama/blob/cfa8d9057004d279508241febf5e97a344300350/products.d/leap_160.yaml#L1
    id: "Leap_16.0"
  },
  localization: {
    language: "en_US.UTF-8",
    keyboard: "us",
    timezone: "America/New_York"
  },
  // Clue: https://agama-project.github.io/docs/user/unattended/users#user
  user: {
    fullName: "John",
    userName: "john",
    hashedPassword: true,
    // Clue: https://agama-project.github.io/docs/user/unattended/users#encrypted-passwords
    password: "$6$5SFO1XN8VAyuwW.G$LaLNJCAAuqCyT.dgEUW9r4VtDSuS4mRvxnWnMaJC4Wc9THz.Uc/SQDxXuY9Kc8zpAJ1G4FKTWou9t/qEZPSAM1"
  },
  root: {
    hashedPassword: $.user.hashedPassword,
    password: $.user.password
  },
  hostname: {
    static: getHostname()
  },
  scripts: {
    post: [
      {
        chroot: true,
        name: "cdn-disable-non-oss",
        content: |||
          #!/bin/bash
          zypper refresh --services
          zypper modifyrepo --disable openSUSE:repo-non-oss openSUSE:update-non-oss
        |||
      },
      {
        chroot: true,
        name: "chrony-dhcp",
        content: |||
          #!/bin/bash
          cp /usr/share/doc/packages/chrony/examples/chrony.nm-dispatcher.dhcp /etc/NetworkManager/dispatcher.d/20-chrony-dhcp
          chmod 755 /etc/NetworkManager/dispatcher.d/20-chrony-dhcp
        |||
      },
      {
        chroot: true,
        name: "chrony-pool-remove",
        content: |||
          #!/bin/bash
          zypper --non-interactive remove chrony-pool-openSUSE
          zypper --non-interactive addlock chrony-pool-openSUSE
          zypper --non-interactive install chrony-pool-empty
        |||
      },
      {
        chroot: true,
        name: "welcome-remove",
        content: |||
          #!/bin/bash
          zypper --non-interactive remove opensuse-welcome
          zypper --non-interactive addlock opensuse-welcome
        |||
      },
      {
        chroot: true,
        name: "wireshark-user",
        content: |||
          #!/bin/bash
          usermod --append --groups wireshark %s
        ||| % $.user.userName
      }
    ] + (
      if board == "PRIME H370M-PLUS" then [
        {
          chroot: true,
          name: "docker-user",
          content: |||
            #!/bin/bash
            usermod --append --groups docker %s
          ||| % $.user.userName
        },
        {
          chroot: true,
          name: "osc-user",
          content: |||
            #!/bin/bash
            usermod --append --groups osc %s
          ||| % $.user.userName
        },
        {
          chroot: true,
          name: "vbox-user",
          content: |||
            #!/bin/bash
            usermod --append --groups vboxusers %s
          ||| % $.user.userName
        }
      ] else []
    ),
    init: [
      {
        name: "mm-disable",
        content: |||
          #!/bin/bash
          systemctl disable ModemManager.service
        |||
      },
      {
        name: "nm-init",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/network-manager.sh"
      }
    ] + (
      if board == "PRIME H370M-PLUS" then [
        {
          name: "vbox-guest-additions",
          // Clue: https://www.virtualbox.org/manual/topics/guestadditions.html#ariaid-title5
          content: |||
            #!/bin/bash
            version=$(VBoxManage --version | cut --delimiter=_ --fields=1)
            curl --cert-status --compressed --create-dirs --no-progress-meter --output-dir /usr/lib/virtualbox/additions --remote-name https://download.virtualbox.org/virtualbox/${version}/VBoxGuestAdditions_${version}.iso
            ln --relative --symbolic /usr/lib/virtualbox/additions/VBoxGuestAdditions_${version}.iso /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso
          |||
        }
      ] else []
    )
  },
  storage: {
    boot: {
      configure: true,
      device: "bootdrive"
    },
    drives: [
      {
        search: drive,
        alias: "bootdrive",
        ptableType: "gpt",
        partitions: [
          {
            search: "*",
            delete: true
          },
          {
            filesystem: {
              type: "ext4",
              path: "/",
              mountBy: "uuid",
              mountOptions: [
                "defaults",
                "noatime"
              ]
            },
            size: "16 GiB"
          },
          {
            encryption: {
              luks2: {
                password: "changeme",
                pbkdFunction: "pbkdf2"
              }
            },
            filesystem: {
              type: "ext4",
              path: "/home",
              mountBy: "uuid",
              mountOptions: [
                "defaults",
                "noatime"
              ]
            }
          },
          {
            encryption: "random_swap",
            filesystem: {
              type: "swap",
              path: "swap"
            },
            size: "2 GiB"
          }
        ]
      }
    ]
  },
  software: {
    patterns: [
      "cockpit",
      "gnome"
    ],
    packages: [
      "avahi-utils",
      "bijiben",
      "chromium",
      "git-core",
      "gstreamer-plugin-openh264",
      "hplip-scan-utils",
      "imagewriter",
      "keepassxc",
      "libcap-ng-utils",
      "libfido2-udev",
      "libpcap-devel",
      "lshw",
      "mozilla-openh264",
      "myrlyn",
      "python313-Pillow-tk",
      "simple-scan",
      "wireshark-ui-qt",
      "yubikey-manager-qt",
      "yubioath-desktop"
    ] + (
      if board == "PRIME H370M-PLUS" then [
        "apcupsd-gui",
        "bash-completion-devel",
        "bash-completion-doc",
        "binwalk",
        "checksec",
        "devscripts",
        "docker-bash-completion",
        "dpkg",
        "gcc-PIE",
        "gcc-ada",
        "gcc-c++",
        "gcc14-PIE",
        "gcc14-ada",
        "gcc14-c++",
        "git-gui",
        "gitk",
        "gnucash",
        "homebank",
        "java-21-openjdk-devel",
        "lighttpd",
        "maven",
        "mkvtoolnix",
        "nvme-cli-bash-completion",
        "osc",
        "pavucontrol",
        "quilt",
        "rpm-devel",
        "rpmdevtools",
        "rpmlint",
        "rpmlint-Factory",
        "virtualbox-qt"
      ] else []
    )
  },
  files: [
    {
      // Clue: https://www.chromium.org/administrators/linux-quick-start/#set-up-policies
      // Clue: https://chromium.googlesource.com/chromium/src/+/HEAD/docs/enterprise/policies.md#policy-sources
      // Clue: chrome://policy/logs
      destination: "/etc/chromium/policies/managed/chromium-policies.json",
      url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/chromium-policies.json",
      permissions: "644",
      user: "root",
      group: "root"
    },
    {
      // Clue: https://mozilla.github.io/policy-templates/
      destination: "/etc/firefox/policies/policies.json",
      url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/firefox-policies.json",
      permissions: "644",
      user: "root",
      group: "root"
    },
    {
      destination: "/etc/security/limits.conf",
      content: |||
        # man limits.conf
        #
        *               soft    core            0
      |||,
      permissions: "644",
      user: "root",
      group: "root"
    }
  ] + (
    if board == "PRIME H370M-PLUS" then [
      {
        destination: "/etc/apcupsd/apcupsd.conf",
        url: "https://raw.githubusercontent.com/serock/agama-profiles/refs/heads/main/apcupsd.conf",
        permissions: "644",
        user: "root",
        group: "root"
      },
      {
        // Clue: https://openbuildservice.org/help/manuals/obs-user-guide/art-obs-bg#pro-obsbg-obsconfig
        destination: "/etc/sudoers.d/osc",
        content: |||
          # sudoers file "/etc/sudoers.d/osc" for the osc group
          Cmnd_Alias  OSC_CMD = /usr/bin/osc, /usr/bin/build
          %osc  ALL = (ALL) NOPASSWD:OSC_CMD
        |||,
        // Clue: visudo --check
        permissions: "440",
        user: "root",
        group: "root"
      }
    ] else []
  )
}
